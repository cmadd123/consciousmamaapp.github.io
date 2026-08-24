// Creator discovery pipeline — queries the Influencers.club API for creators
// matching filters (platform, follower range, US, engagement, niche via NLP),
// optionally enriches for verified email, and drops the results straight into
// the outreach CRM (outreach_leads). The outbound half of creator recruitment.
//
// Cost-aware: discovery is ~0.01 credit/creator; email enrichment is 1 credit
// each (only when data is returned). The count is capped and enrichment is
// opt-in so a single call can't blow the credit budget.
//
// Gated to the CRM allowlist (Collin, Brennan, Haley) — same people who use
// the CRM, not full admins.

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

const INFLUENCERS_CLUB_API_KEY = defineSecret('INFLUENCERS_CLUB_API_KEY');
const API = 'https://api-dashboard.influencers.club/public/v1';
const CRM_EMAILS = ['collinjmaddox@gmail.com', 'brennanmaddox27@gmail.com', 'haley.hostetter@gmail.com'];

function requireCrm(request) {
  const email = (request.auth?.token?.email || '').toLowerCase();
  if (!CRM_EMAILS.includes(email)) throw new HttpsError('permission-denied', 'CRM access required');
}

async function icPost(path, body) {
  const res = await fetch(`${API}${path}`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${INFLUENCERS_CLUB_API_KEY.value()}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(`Influencers.club ${res.status}: ${JSON.stringify(data).slice(0, 200)}`);
  return data;
}

exports.findCreators = onCall(
  { secrets: [INFLUENCERS_CLUB_API_KEY], timeoutSeconds: 300 },
  async (request) => {
    requireCrm(request);
    const d = request.data || {};
    const platform = String(d.platform || 'instagram').toLowerCase();
    const platformLabel = platform.charAt(0).toUpperCase() + platform.slice(1);
    const count = Math.max(1, Math.min(Number(d.count) || 25, 50));   // hard cap 50/call
    const fetchEmails = d.fetchEmails !== false;                       // default true

    const filters = {
      location: ['United States'],
      number_of_followers: { min: Number(d.followersMin) || 5000, max: Number(d.followersMax) || 15000 },
      profile_language: ['en'],
    };
    if (d.engagementMin) filters.engagement_percent = { min: Number(d.engagementMin) };

    // 1) Discovery — page until we have `count` candidates (cheap: ~0.01/creator)
    const candidates = [];
    let creditsLeft = null;
    for (let page = 0; candidates.length < count && page < 25; page++) {
      const body = { platform, filters, paging: { limit: Math.min(50, count - candidates.length), page } };
      if (d.nlpSearch) body.nlp_search = String(d.nlpSearch);
      const r = await icPost('/discovery/', body);
      if (typeof r.credits_left === 'number') creditsLeft = r.credits_left;
      const accts = r.accounts || [];
      if (accts.length === 0) break;
      for (const a of accts) {
        const p = a.profile || {};
        if (p.username) candidates.push({ username: p.username, name: p.full_name || '', followers: p.followers ?? null, engagement: p.engagement_percent ?? null });
      }
    }

    // Dedupe against what's already in the CRM (by handle).
    const db = getFirestore();
    const snap = await db.collection('outreach_leads').get();
    const existing = new Set();
    snap.forEach((x) => { const h = (x.data().handle || '').replace(/^@/, '').toLowerCase(); if (h) existing.add(h); });

    let added = 0, skipped = 0, enriched = 0;
    for (const c of candidates) {
      const key = c.username.toLowerCase();
      if (existing.has(key)) { skipped++; continue; }
      existing.add(key);

      let email = '', gender = '', first = '';
      if (fetchEmails) {
        try {
          const e = await icPost('/creators/enrich/handle/full/', {
            handle: c.username, platform, email_required: 'preferred', include_audience_data: false,
          });
          const rr = e.result || {};
          email = String(rr.email || '').toLowerCase();
          gender = rr.gender || '';
          first = rr.first_name || '';
          if (email || first) enriched++;
        } catch (_) { /* skip enrichment failure, still add the lead */ }
      }

      const notes = [
        c.engagement != null ? `Engagement ${Number(c.engagement).toFixed(1)}%` : '',
        gender ? `Gender: ${gender}` : '',
        'via Influencers.club',
      ].filter(Boolean).join(' · ');

      await db.collection('outreach_leads').add({
        name: c.name || first || c.username,
        handle: '@' + c.username,
        platform: platformLabel,
        email,
        followers: c.followers,
        status: 'to_contact',
        last_contacted: '',
        follow_up_date: '',
        notes,
        source: 'influencers_club',
        created_at: FieldValue.serverTimestamp(),
        created_by: request.auth.token.email,
        updated_at: FieldValue.serverTimestamp(),
      });
      added++;
    }

    return { discovered: candidates.length, added, skipped, enriched, credits_left: creditsLeft };
  },
);
