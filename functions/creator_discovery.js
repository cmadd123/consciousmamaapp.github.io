// Creator discovery pipeline — queries the Influencers.club API for creators
// matching filters (platform, follower range, US, gender, engagement, niche via
// NLP), enriches for verified email, AI-scores each for MomRise partnership fit
// with a suggested opener, and drops the results into the outreach CRM
// (outreach_leads). The outbound half of creator recruitment.
//
// Cost-aware: discovery is ~0.01 credit/creator; email enrichment is 1 credit
// each (only when data is returned). The count is capped and enrichment is
// opt-in so a single call can't blow the credit budget. AI scoring is one
// batched LLM call per run (via llm_router — Sonnet), not one call per creator.
//
// Gated to the CRM allowlist (Collin, Brennan, Haley) — same people who use
// the CRM, not full admins.

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { generate } = require('./llm_router');

const INFLUENCERS_CLUB_API_KEY = defineSecret('INFLUENCERS_CLUB_API_KEY');
const ANTHROPIC_API_KEY = defineSecret('ANTHROPIC_API_KEY');
const OPENAI_API_KEY = defineSecret('OPENAI_API_KEY');
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

// One batched LLM call to score all fresh creators for MomRise fit + draft an
// opener each. Returns a map: lowercased handle -> { fit_score, opener }.
async function scoreCreators(fresh, userEmail) {
  if (!fresh.length) return {};
  const list = fresh.map((c) => ({
    handle: c.username,
    name: c.name || '',
    followers: c.followers,
    engagement: c.engagement != null ? Number(c.engagement).toFixed(1) : null,
    gender: c.gender || '',
    interests: (c.interests || []).slice(0, 6),
  }));
  const system =
    'You help MomRise (a family meal-planning + parenting app) recruit creator partners. ' +
    'A strong partner is a US-based family / food / recipe / mom micro-creator (roughly 5k–15k ' +
    'followers) with an engaged audience who would authentically recommend a meal-planning app ' +
    'to fellow parents. Rate partnership fit from 0 to 100 (higher = better fit) and write one ' +
    'short, warm, personalized outreach opener per creator: a single sentence, no emojis, that ' +
    'references their niche or handle naturally and does not sound salesy or templated.';
  const prompt =
    'Score each creator for MomRise partnership fit and draft an opener. ' +
    'Return ONLY a JSON array — one object per creator, no prose, no code fences — of the form ' +
    '[{"handle":"<their handle>","fit_score":<0-100 integer>,"opener":"<one sentence>"}].\n\n' +
    JSON.stringify(list);

  let text = '';
  try {
    text = await generate({ task: 'creatorScore', userId: userEmail, prompt, systemPrompt: system });
  } catch (_) { return {}; }

  // Parse defensively — strip code fences, grab the array.
  const map = {};
  try {
    const m = text.match(/\[[\s\S]*\]/);
    const arr = JSON.parse(m ? m[0] : text);
    for (const row of arr) {
      const h = String(row.handle || '').replace(/^@/, '').toLowerCase();
      if (!h) continue;
      const score = Number(row.fit_score);
      map[h] = {
        fit_score: Number.isFinite(score) ? Math.max(0, Math.min(100, Math.round(score))) : null,
        opener: String(row.opener || '').trim(),
      };
    }
  } catch (_) { /* leave map empty; leads still get added without scores */ }
  return map;
}

exports.findCreators = onCall(
  { secrets: [INFLUENCERS_CLUB_API_KEY, ANTHROPIC_API_KEY, OPENAI_API_KEY], timeoutSeconds: 300 },
  async (request) => {
    requireCrm(request);
    const d = request.data || {};
    const platform = String(d.platform || 'instagram').toLowerCase();
    const platformLabel = platform.charAt(0).toUpperCase() + platform.slice(1);
    const count = Math.max(1, Math.min(Number(d.count) || 25, 50));   // hard cap 50/call
    const fetchEmails = d.fetchEmails !== false;                       // default true
    const gender = String(d.gender || '').toLowerCase();               // '', 'female', 'male'

    const filters = {
      location: ['United States'],
      number_of_followers: { min: Number(d.followersMin) || 5000, max: Number(d.followersMax) || 15000 },
      profile_language: ['en'],
    };
    if (d.engagementMin) filters.engagement_percent = { min: Number(d.engagementMin) };
    if (gender === 'female' || gender === 'male') filters.gender = gender;   // string, not array

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

    // 2) Dedupe against what's already in the CRM (by handle) — before enriching,
    //    so we never spend enrichment credits on a creator we already have.
    const db = getFirestore();
    const snap = await db.collection('outreach_leads').get();
    const existing = new Set();
    snap.forEach((x) => { const h = (x.data().handle || '').replace(/^@/, '').toLowerCase(); if (h) existing.add(h); });

    let skipped = 0;
    const fresh = [];
    for (const c of candidates) {
      const key = c.username.toLowerCase();
      if (existing.has(key)) { skipped++; continue; }
      existing.add(key);
      fresh.push(c);
    }

    // 3) Enrich each fresh creator (email + demographics), attaching to the object.
    let enriched = 0;
    if (fetchEmails) {
      for (const c of fresh) {
        try {
          const e = await icPost('/creators/enrich/handle/full/', {
            handle: c.username, platform, email_required: 'preferred', include_audience_data: false,
          });
          const rr = e.result || {};
          c.email = String(rr.email || '').toLowerCase();
          c.gender = rr.gender || '';
          c.first = rr.first_name || '';
          c.interests = rr.audience_interests || [];
          if (c.email || c.first) enriched++;
        } catch (_) { /* skip enrichment failure, still add the lead */ }
      }
    }

    // 4) AI scoring — one batched call for the whole fresh set.
    const scores = await scoreCreators(fresh, request.auth.token.email);

    // 5) Write each fresh lead with fit score + suggested opener.
    let added = 0;
    for (const c of fresh) {
      const s = scores[c.username.toLowerCase()] || {};
      const notes = [
        c.engagement != null ? `Engagement ${Number(c.engagement).toFixed(1)}%` : '',
        c.gender ? `Gender: ${c.gender}` : '',
        'via Influencers.club',
      ].filter(Boolean).join(' · ');

      await db.collection('outreach_leads').add({
        name: c.name || c.first || c.username,
        handle: '@' + c.username,
        platform: platformLabel,
        email: c.email || '',
        followers: c.followers,
        status: 'to_contact',
        last_contacted: '',
        follow_up_date: '',
        notes,
        fit_score: s.fit_score ?? null,
        suggested_opener: s.opener || '',
        source: 'influencers_club',
        created_at: FieldValue.serverTimestamp(),
        created_by: request.auth.token.email,
        updated_at: FieldValue.serverTimestamp(),
      });
      added++;
    }

    return { discovered: candidates.length, added, skipped, enriched, scored: Object.keys(scores).length, credits_left: creditsLeft };
  },
);
