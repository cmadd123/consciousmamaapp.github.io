// MomRise — App Store Server Notifications V2 webhook
//
// Apple's IAP runs payments outside our backend, so creator earnings
// from iOS revenue can only be credited via Server-to-Server (S2S)
// notifications: Apple POSTs a signed JWS payload to this endpoint on
// every subscription event (purchase, renewal, refund, expiration).
//
// Flow:
//   1. App passes appAccountToken (UUID) on every iOS IAP — see
//      lib/custom_code/actions/iap_service.dart::_ensureAppAccountToken
//   2. Apple includes that token in the signed transactionInfo
//   3. This webhook decodes + verifies the JWS, reads appAccountToken,
//      looks up users by apple_app_account_token, reads
//      active_creator_code, and credits the matching creator at 50%.
//
// Schema: rows match the Stripe path (creator_earnings collection) so
// the dashboard reads both transparently. Distinguishing field is
// `source: 'apple_iap'` (Stripe rows leave it unset / use 'stripe').

const { onRequest } = require('firebase-functions/v2/https');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const {
  SignedDataVerifier,
  Environment,
} = require('@apple/app-store-server-library');
const fs = require('fs');
const path = require('path');

// Default creator rev share. Overridden per creator via creator.rev_share
// (number in (0, 1]). Kept in sync with stripe_functions.js — both files
// use the same default and the same per-creator override field.
const DEFAULT_CREATOR_REV_SHARE = 0.5;

function getCreatorRevShare(creator) {
  const v = creator?.rev_share;
  if (typeof v === 'number' && v > 0 && v <= 1) return v;
  return DEFAULT_CREATOR_REV_SHARE;
}

const BUNDLE_ID = 'com.momrise.app';
const APPLE_APP_ID = 6758357382; // momrise.app App Store ID

// Apple's price field is sometimes null in sandbox (and historically
// wasn't on every transaction in production either). Look up by product
// ID as the primary source so earnings always write at the right amount;
// fall back to the signed price only if we don't recognize the product.
const PRODUCT_PRICES_CENTS = {
  'momrise_month': 699,   // $6.99
  'momrise_year': 6999,   // $69.99
};

// Apple Root CA G3 — vendored as a DER cert next to this file. Source:
//   https://www.apple.com/certificateauthority/AppleRootCA-G3.cer
// The library accepts DER-encoded Buffer/Uint8Array of trusted root
// certs. Read once at module load, reuse across invocations within a
// warm container.
let APPLE_ROOT_DERS = null;
function loadAppleRoots() {
  if (APPLE_ROOT_DERS) return APPLE_ROOT_DERS;
  const certPath = path.join(__dirname, 'apple_root_ca_g3.cer');
  APPLE_ROOT_DERS = [fs.readFileSync(certPath)];
  return APPLE_ROOT_DERS;
}

// Decode the middle (payload) segment of a JWS without verifying the
// signature, just to read the `data.environment` field. We need this to
// pick the right verifier because the library binds env at construction
// and the env field is NOT exposed at the HTTP body level — it's inside
// the signed payload. Falls back to Production if anything looks off so
// real production traffic still flows in the unlikely event of a parse
// blip.
function peekJwsEnvironment(signedPayload) {
  try {
    const parts = String(signedPayload).split('.');
    if (parts.length !== 3) return 'Production';
    const payloadB64 = parts[1].replace(/-/g, '+').replace(/_/g, '/');
    const padded = payloadB64 + '='.repeat((4 - (payloadB64.length % 4)) % 4);
    const json = Buffer.from(padded, 'base64').toString('utf8');
    const obj = JSON.parse(json);
    return obj.data?.environment === 'Sandbox' ? 'Sandbox' : 'Production';
  } catch (_) {
    return 'Production';
  }
}

// Separate verifier per environment because the library binds env at
// construction time. Production notifications and Sandbox notifications
// have different signing chains.
const verifierCache = new Map();
function getVerifier(environment) {
  if (verifierCache.has(environment)) return verifierCache.get(environment);
  const env = environment === 'Production'
    ? Environment.PRODUCTION
    : Environment.SANDBOX;
  const v = new SignedDataVerifier(
    loadAppleRoots(),
    /* enableOnlineChecks */ false,
    env,
    BUNDLE_ID,
    APPLE_APP_ID,
  );
  verifierCache.set(environment, v);
  return v;
}

/**
 * HTTP endpoint Apple posts notifications to. Configure in App Store
 * Connect → App Information → App Store Server Notifications:
 *   Production URL: https://us-central1-parenting-plus-7szrif.cloudfunctions.net/appleNotification
 *   Sandbox URL:    same URL — we route by the environment field in
 *                   the payload so one endpoint serves both.
 *
 * Apple expects a 2xx response within 10s. If we error, Apple retries
 * with backoff (up to ~3 days). The function is idempotent on
 * transactionId so retries don't double-credit.
 */
exports.appleNotification = onRequest(
  { cors: false, memory: '512MiB', timeoutSeconds: 60 },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).send('Method not allowed');
      return;
    }

    const signedPayload = req.body?.signedPayload;
    if (!signedPayload) {
      console.error('[apple_iap] missing signedPayload');
      res.status(400).send('Missing signedPayload');
      return;
    }

    try {
      // The environment field lives INSIDE the signed JWS payload, not
      // at the top level of req.body. Peek at the unverified payload to
      // pick the right verifier — the library binds env at construction
      // and rejects with INVALID_ENVIRONMENT if the decoded payload's
      // env doesn't match the verifier's. Safe to read unverified
      // because we still verify the full signature below.
      const envEnv = peekJwsEnvironment(signedPayload);
      const v = getVerifier(envEnv);
      const decoded = await v.verifyAndDecodeNotification(signedPayload);

      const notificationType = decoded.notificationType;
      const subtype = decoded.subtype || null;
      const notificationUUID = decoded.notificationUUID;
      const data = decoded.data || {};

      console.log(
        `[apple_iap] ${notificationType}` +
          (subtype ? `/${subtype}` : '') +
          ` uuid=${notificationUUID}`,
      );

      // Idempotency: every notification has a stable notificationUUID
      // — Apple resends the same UUID on retries. Skip if we've seen
      // it before.
      const db = getFirestore();
      const seenRef = db
        .collection('apple_notifications_seen')
        .doc(notificationUUID);
      const seenSnap = await seenRef.get();
      if (seenSnap.exists) {
        console.log(`[apple_iap] duplicate ${notificationUUID}, ignoring`);
        res.status(200).send('OK (duplicate)');
        return;
      }
      await seenRef.set({
        notification_type: notificationType,
        subtype,
        received_at: FieldValue.serverTimestamp(),
      });

      // Pull the inner signed transaction + renewal info, both JWS
      // signed independently by Apple.
      const txInfo = data.signedTransactionInfo
        ? await v.verifyAndDecodeTransaction(data.signedTransactionInfo)
        : null;
      const renewalInfo = data.signedRenewalInfo
        ? await v.verifyAndDecodeRenewalInfo(data.signedRenewalInfo)
        : null;

      // Earning events: any path where money landed in Apple's
      // coffers. Apple's notification types are surprisingly tangled —
      // these are the ones that represent NEW revenue:
      //   SUBSCRIBED/INITIAL_BUY      — first-ever purchase after trial
      //   SUBSCRIBED/RESUBSCRIBE      — lapsed user came back
      //   DID_RENEW                   — auto-renewal succeeded
      //   OFFER_REDEEMED              — promo / win-back offer
      // Trial conversions also fire DID_RENEW when the trial ends and
      // the first paid period kicks in.
      const earningTypes = new Set([
        'SUBSCRIBED',
        'DID_RENEW',
        'OFFER_REDEEMED',
      ]);
      if (earningTypes.has(notificationType) && txInfo) {
        await recordAppleEarning(txInfo, notificationType, subtype, envEnv);
      }

      // Refund events: Apple yanks money back, sometimes weeks after
      // the original transaction. Create a clawback row.
      const refundTypes = new Set(['REFUND']);
      if (refundTypes.has(notificationType) && txInfo) {
        await recordAppleRefundClawback(txInfo, envEnv);
      }

      // Everything else (EXPIRED, DID_CHANGE_RENEWAL_STATUS, etc.) we
      // log but don't mutate creator_earnings on. We may want to
      // surface these in a creator's lifecycle view later.

      res.status(200).send('OK');
    } catch (err) {
      console.error('[apple_iap] processing error:', err);
      // 500 → Apple retries. Safe because we're idempotent on
      // notificationUUID. Only return 400 for unrecoverable parse
      // errors (which we already do above for missing payload).
      res.status(500).send('Processing error');
    }
  },
);

async function recordAppleEarning(txInfo, notificationType, subtype, environment) {
  const db = getFirestore();
  const transactionId = txInfo.transactionId;
  const originalTransactionId = txInfo.originalTransactionId;
  const appAccountToken = txInfo.appAccountToken;

  if (!appAccountToken) {
    console.warn(
      `[apple_iap] tx ${transactionId} has no appAccountToken — ` +
        'cannot attribute. User installed before app set the token, ' +
        'or token was stripped (not a valid UUID).',
    );
    return;
  }

  // Idempotency at the row level too — a different notificationUUID
  // could still carry the same transactionId in some edge cases. Once
  // we've credited a transaction, don't credit it twice.
  const existing = await db
    .collection('creator_earnings')
    .where('transaction_id', '==', transactionId)
    .limit(1)
    .get();
  if (!existing.empty) {
    console.log(
      `[apple_iap] tx ${transactionId} already credited, skipping`,
    );
    return;
  }

  // Look up the Firebase user by appAccountToken. This is the bridge
  // between Apple's transaction and our user model.
  const userSnap = await db
    .collection('users')
    .where('apple_app_account_token', '==', appAccountToken)
    .limit(1)
    .get();
  if (userSnap.empty) {
    console.warn(
      `[apple_iap] no user found for appAccountToken=${appAccountToken} ` +
        `(tx ${transactionId}). Token mismatch?`,
    );
    return;
  }
  const userDoc = userSnap.docs[0];
  const creatorCode = userDoc.data().active_creator_code;
  if (!creatorCode) {
    // No creator attribution → no row to create. Normal case for
    // organic users (no creator code entered).
    return;
  }

  const creatorSnap = await db
    .collection('creators')
    .where('code', '==', creatorCode)
    .limit(1)
    .get();
  if (creatorSnap.empty) {
    console.warn(
      `[apple_iap] user ${userDoc.id} has active_creator_code=${creatorCode} ` +
        'but no matching creator doc. Code revoked?',
    );
    return;
  }
  const creatorDoc = creatorSnap.docs[0];
  const creator = creatorDoc.data();

  // Same policy as the Stripe path — creator must be Connect-onboarded
  // before earnings start accruing. Earnings credited before
  // onboarding would have nowhere to pay out to.
  if (!creator.stripe_connect_onboarded) {
    console.log(
      `[apple_iap] skipping earning for creator ${creatorCode}: not onboarded`,
    );
    return;
  }

  // Resolve price. Prefer our product-ID table (deterministic, always
  // present); fall back to Apple's signed price field (milliunits — $6.99
  // = 6990 milliunits, divide by 10 for cents). The signed price is
  // sometimes null on sandbox transactions and historically wasn't on
  // every production transaction either, so the table is the safer floor.
  const productId = txInfo.productId;
  let grossCents = PRODUCT_PRICES_CENTS[productId] || 0;
  if (grossCents === 0 && txInfo.price != null) {
    grossCents = Math.round(txInfo.price / 10);
  }
  if (grossCents <= 0) {
    console.warn(
      `[apple_iap] tx ${transactionId} no price (product=${productId}, ` +
        `signed_price=${txInfo.price}) — free trial / unknown product?`,
    );
    return;
  }
  const revShare = getCreatorRevShare(creator);
  const creatorCents = Math.round(grossCents * revShare);

  await db.collection('creator_earnings').add({
    creator_ref: creatorDoc.ref,
    creator_code: creatorCode,
    user_ref: userDoc.ref,
    transaction_id: transactionId,
    original_transaction_id: originalTransactionId,
    product_id: txInfo.productId,
    gross_cents: grossCents,
    creator_cents: creatorCents,
    rev_share: revShare,
    currency: (txInfo.currency || 'USD').toLowerCase(),
    period_start: txInfo.purchaseDate
      ? new Date(txInfo.purchaseDate)
      : null,
    period_end: txInfo.expiresDate
      ? new Date(txInfo.expiresDate)
      : null,
    payout_status: 'pending',
    created_at: FieldValue.serverTimestamp(),
    kind: 'earning',
    source: 'apple_iap',
    apple_notification_type: notificationType,
    apple_subtype: subtype,
    environment, // 'Production' or 'Sandbox' — payouts filter on this
  });

  console.log(
    `[apple_iap] earning recorded: tx=${transactionId} creator=${creatorCode} ` +
      `gross=${grossCents}¢ creator=${creatorCents}¢`,
  );
}

async function recordAppleRefundClawback(txInfo, environment) {
  const db = getFirestore();
  const transactionId = txInfo.transactionId;

  // Find the original earning row to mirror.
  const earningSnap = await db
    .collection('creator_earnings')
    .where('transaction_id', '==', transactionId)
    .where('kind', '==', 'earning')
    .limit(1)
    .get();
  if (earningSnap.empty) {
    console.log(
      `[apple_iap] refund for tx ${transactionId} has no prior earning — ` +
        'either organic (no creator attribution) or refunded before our ' +
        'webhook saw the purchase. Skipping clawback.',
    );
    return;
  }
  const earning = earningSnap.docs[0].data();

  // Idempotency: only one clawback per transaction.
  const existing = await db
    .collection('creator_earnings')
    .where('transaction_id', '==', transactionId)
    .where('kind', '==', 'clawback')
    .limit(1)
    .get();
  if (!existing.empty) {
    console.log(
      `[apple_iap] clawback for tx ${transactionId} already exists, skipping`,
    );
    return;
  }

  await db.collection('creator_earnings').add({
    creator_ref: earning.creator_ref,
    creator_code: earning.creator_code,
    user_ref: earning.user_ref,
    transaction_id: transactionId,
    original_transaction_id: earning.original_transaction_id || null,
    product_id: earning.product_id || null,
    gross_cents: -earning.gross_cents,
    creator_cents: -earning.creator_cents,
    rev_share: earning.rev_share || DEFAULT_CREATOR_REV_SHARE,
    currency: earning.currency || 'usd',
    payout_status: 'pending',
    created_at: FieldValue.serverTimestamp(),
    kind: 'clawback',
    source: 'apple_iap',
    source_earning_ref: earningSnap.docs[0].ref,
    environment, // 'Production' or 'Sandbox'
  });

  console.log(
    `[apple_iap] clawback recorded: tx=${transactionId} creator=${earning.creator_code} ` +
      `${earning.gross_cents}¢ → reversed`,
  );
}
