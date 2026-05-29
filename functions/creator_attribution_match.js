// "Poor man's Branch" — server-side fingerprint match for deferred deep
// linking without paying for Branch ($140/mo) or AppsFlyer.
//
// Flow:
//   1. Follower lands on momrise.app/c/HALEY. Web JS POSTs to
//      recordPendingAttribution with the creator code + a device
//      fingerprint (IP from request headers + user-agent + screen +
//      language + timezone). Server stores in
//      pending_attributions/{autoId} with an expires_at 24h out.
//   2. Follower installs MomRise from the App Store (5-15 min).
//   3. On first app launch (or whenever we don't have
//      active_creator_code set), app POSTs to claimAttribution with
//      its own device fingerprint. Server queries pending docs from
//      the same IP within the TTL window and picks the best match.
//   4. If matched, server writes active_creator_code on the user doc
//      and deletes the pending row.
//
// Expected accuracy: 60-75%, lower than Branch's 85-95% because we're
// only matching on coarse signals (no IDFA fallback, no SDK
// cross-checks). But ~free to operate — only Firestore reads/writes.
//
// Failure modes that are OK:
//   - Wi-Fi on web, cellular on app open → IP mismatch → no claim
//     (user falls back to manual entry).
//   - Multiple installs from same IP in 24h (e.g. family on same
//     network) → all attributed to the most recent code. Edge case;
//     acceptable.
//
// Failure modes that aren't OK:
//   - Stale pending rows pile up forever → use Firestore TTL on
//     expires_at (configured via Firebase console after first deploy)
//     to auto-delete after 30 days as a backstop.

const { onCall, onRequest, HttpsError } = require('firebase-functions/v2/https');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');

// Pending attribution rows live ~24h. Longer TTL = more ghost matches
// (someone clicks Haley's link Monday, installs the app Friday →
// definitely not really Haley's referral). Shorter TTL = more misses
// from busy moms who don't install immediately.
const PENDING_TTL_HOURS = 24;

/**
 * Record a creator-code visit from the web /c/{code} landing page.
 * Public endpoint (no auth) since the follower hasn't installed the
 * app yet. Rate-limited per IP at the cloud-functions tier; if abuse
 * shows up, layer on Firebase App Check.
 *
 * Request body: { code: "HALEY", screen: "390x844", language: "en-US",
 *                 timezone_offset_minutes: -300 }
 * The IP and user-agent come from request headers.
 */
exports.recordPendingAttribution = onRequest(
  { cors: true, memory: '256MiB' },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).send('Method not allowed');
      return;
    }

    const body = req.body || {};
    const code = (body.code || '').toString().trim().toUpperCase();
    if (!/^[A-Z0-9]{3,20}$/.test(code)) {
      res.status(400).json({ error: 'Invalid code format.' });
      return;
    }

    // Strip the fingerprint to small, server-derivable bits. We don't
    // store the raw user-agent because UA strings are PII-adjacent under
    // some interpretations and the prefix is just as good for matching.
    const ip = (req.headers['x-forwarded-for'] || req.ip || '')
      .toString()
      .split(',')[0]
      .trim();
    if (!ip) {
      res.status(400).json({ error: 'No client IP — request rejected.' });
      return;
    }
    const userAgent = (req.headers['user-agent'] || '').toString().slice(0, 200);
    const screen = (body.screen || '').toString().slice(0, 20);
    const language = (body.language || '').toString().slice(0, 10);
    const tzOffset = Number.isFinite(Number(body.timezone_offset_minutes))
      ? Number(body.timezone_offset_minutes)
      : null;

    // Verify the code points to a real creator before storing the row.
    // No reason to clutter the table with bogus codes from typos / bots.
    const db = getFirestore();
    const creatorSnap = await db
      .collection('creators')
      .where('code', '==', code)
      .limit(1)
      .get();
    if (creatorSnap.empty) {
      // Return 200 so misconfigured share links don't appear as scary
      // errors in browser dev tools — the landing page still works.
      res.status(200).json({ ok: false, reason: 'unknown_code' });
      return;
    }

    const expiresAt = new Date(
      Date.now() + PENDING_TTL_HOURS * 60 * 60 * 1000,
    );
    await db.collection('pending_attributions').add({
      code,
      creator_ref: creatorSnap.docs[0].ref,
      ip,
      user_agent_prefix: userAgent.slice(0, 80),
      screen,
      language,
      timezone_offset_minutes: tzOffset,
      created_at: FieldValue.serverTimestamp(),
      expires_at: Timestamp.fromDate(expiresAt),
    });

    res.status(200).json({ ok: true });
  },
);

/**
 * Called from the iOS app on first launch (or any time the user has no
 * active_creator_code). Looks for a pending_attributions row matching
 * the device's IP + user-agent prefix + screen size, claims it, and
 * writes active_creator_code to the user doc.
 *
 * Authenticated — we need the caller's uid to write the user doc.
 *
 * Request data: { user_agent: "...", screen: "...", language: "...",
 *                 timezone_offset_minutes: -300 }
 * The server reads the IP from request headers (same as web).
 *
 * Returns: { matched: bool, code: string|null, creator_name: string|null }
 */
exports.claimAttribution = onCall(
  { memory: '256MiB' },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in required.');
    }
    const uid = request.auth.uid;

    const db = getFirestore();
    const userRef = db.collection('users').doc(uid);

    // If the user already has a creator code set (e.g. they entered it
    // manually via the welcome sheet or Settings), don't overwrite.
    // First-attribution wins — this is the policy that matches the
    // Stripe path's "active_creator_code at invoice time" rule.
    const userSnap = await userRef.get();
    if (userSnap.exists && userSnap.data().active_creator_code) {
      return {
        matched: false,
        reason: 'already_attributed',
        code: userSnap.data().active_creator_code,
        creator_name: null,
      };
    }

    const data = request.data || {};
    const ip = (request.rawRequest?.headers['x-forwarded-for'] ||
      request.rawRequest?.ip || '')
      .toString()
      .split(',')[0]
      .trim();
    const userAgentPrefix = (data.user_agent || '').toString().slice(0, 80);
    const screen = (data.screen || '').toString().slice(0, 20);

    // Query for pending rows from the same IP, not yet expired.
    // The "best match" picker below applies finer-grained fingerprint
    // comparison. We pull up to 50 candidates from the same IP — in
    // practice a single IP shouldn't have more than a handful of
    // pending rows within 24h unless it's a coffee shop / school WiFi
    // with multiple recent visitors.
    const cutoff = Timestamp.fromDate(new Date());
    const candidates = await db
      .collection('pending_attributions')
      .where('ip', '==', ip)
      .where('expires_at', '>', cutoff)
      .orderBy('expires_at', 'desc')
      .limit(50)
      .get();

    if (candidates.empty) {
      return { matched: false, reason: 'no_pending', code: null, creator_name: null };
    }

    // Score each candidate. Higher is better.
    let best = null;
    let bestScore = -1;
    for (const doc of candidates.docs) {
      const c = doc.data();
      let score = 1; // IP match is the floor
      // User-agent platform match — iPhone web vs iPhone app: both UAs
      // contain "iPhone" / "iOS". This is coarse but reliable across
      // the same device's browser↔app boundary.
      const cua = (c.user_agent_prefix || '').toLowerCase();
      const aua = userAgentPrefix.toLowerCase();
      if (cua && aua && (cua.includes('iphone') === aua.includes('iphone'))) {
        score += 1;
      }
      // Screen-size match is the strongest signal (specific device).
      if (c.screen && screen && c.screen === screen) {
        score += 3;
      }
      // Recency tiebreaker — assume the user clicks the link, then
      // installs within minutes. The most recent pending row from this
      // IP is most likely to be theirs.
      const createdAtMs = c.created_at?.toMillis?.() ?? 0;
      score += createdAtMs / 1e13; // tiny tiebreaker, never overrides screen match
      if (score > bestScore) {
        best = { ref: doc.ref, data: c, score };
        bestScore = score;
      }
    }

    if (!best || bestScore < 1) {
      return { matched: false, reason: 'no_match', code: null, creator_name: null };
    }

    const code = best.data.code;

    // Look up creator's display name for the success message.
    let creatorName = null;
    try {
      const creatorSnap = await best.data.creator_ref.get();
      if (creatorSnap.exists) {
        creatorName = creatorSnap.data().name || null;
      }
    } catch (_) {
      // creator_ref may be stale if the creator got deleted; just skip
      // the name lookup and let the row write succeed anyway.
    }

    await userRef.set(
      {
        active_creator_code: code,
        active_creator_code_set_at: FieldValue.serverTimestamp(),
        active_creator_code_source: 'fingerprint_match',
      },
      { merge: true },
    );

    // Delete the claimed pending row so a second device on the same IP
    // doesn't double-claim. Other candidate rows from the same IP stay
    // — they're for someone else who hasn't installed yet.
    await best.ref.delete();

    return {
      matched: true,
      code,
      creator_name: creatorName,
      score: bestScore,
    };
  },
);
