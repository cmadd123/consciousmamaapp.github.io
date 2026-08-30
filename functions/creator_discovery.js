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

// Recursively find a key's first non-empty value in a nested object.
function deepFind(obj, key) {
  if (!obj || typeof obj !== 'object') return null;
  if (obj[key] != null && obj[key] !== '') return obj[key];
  for (const k of Object.keys(obj)) {
    const v = deepFind(obj[k], key);
    if (v != null && v !== '') return v;
  }
  return null;
}

function profileUrl(platform, username) {
  const u = String(username || '').replace(/^@/, '');
  if (platform === 'tiktok') return `https://www.tiktok.com/@${u}`;
  return `https://www.instagram.com/${u}`;
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

// Authoritative remaining-credit balance (free GET) — call after all spending
// so the number reflects discovery + enrichment, not the mid-run discovery value.
async function icCreditsLeft() {
  try {
    const res = await fetch(`${API}/accounts/credits/`, {
      headers: { Authorization: `Bearer ${INFLUENCERS_CLUB_API_KEY.value()}` },
    });
    const data = await res.json().catch(() => ({}));
    return typeof data.credits_available === 'number' ? data.credits_available : null;
  } catch (_) { return null; }
}

// One batched LLM call to score creators for MomRise partnership fit AND draft
// a bio-aware outreach opener for each. Learns from Haley's past decisions via
// the `calibration` examples. Returns a map: lowercased handle -> { fit_score, opener }.
async function scoreCreators(fresh, userEmail, calibration) {
  if (!fresh.length) return {};
  const list = fresh.map((c) => ({
    handle: c.username,
    name: c.name || '',
    bio: (c.bio || '').slice(0, 300),
    category: c.category || '',
    followers: c.followers,
    engagement: c.engagement != null ? Number(c.engagement).toFixed(1) : null,
    gender: c.gender || '',
    interests: (c.interests || []).slice(0, 6),
  }));
  let system =
    'You help MomRise (a family meal-planning + parenting app) recruit creator partners. ' +
    'A strong partner is a US-based family / food / recipe / mom micro-creator (roughly 5k–15k ' +
    'followers) with an engaged audience who would authentically recommend a meal-planning app ' +
    'to fellow parents. Weigh each creator\'s bio and category heavily — that\'s what they actually ' +
    'post about — over the handle alone. Rate each creator\'s partnership fit from 0 to 100 ' +
    '(higher = better fit), and write one short, warm, personalized outreach opener per creator: ' +
    'a single sentence, no emojis, that references their bio/niche naturally and does not sound ' +
    'salesy or templated.';
  // Learning loop: calibrate to Haley's real decisions.
  if (calibration && (calibration.pursued?.length || calibration.passed?.length)) {
    system += '\n\nCalibrate to the recruiter\'s actual track record. Creators she PURSUED ' +
      '(good fits): ' + JSON.stringify((calibration.pursued || []).slice(0, 15)) +
      '. Creators she PASSED on (poor fits): ' + JSON.stringify((calibration.passed || []).slice(0, 15)) +
      '. Score new creators the way she would, based on these patterns.';
  }
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

// Build the learning-loop calibration set from Haley's past decisions.
// Pursued (replied/in_talks/signed) = good; passed = bad. Compact bio snapshots.
async function getCalibration(db) {
  const out = { pursued: [], passed: [] };
  try {
    const snap = await db.collection('outreach_leads').get();
    const pursuedStatuses = new Set(['replied', 'in_talks', 'signed']);
    snap.forEach((doc) => {
      const x = doc.data();
      const ex = { name: x.name || x.handle || '', bio: (x.bio || '').slice(0, 160), category: x.category || '' };
      if (!ex.bio && !ex.category) return;                 // no signal without bio/category
      if (x.feedback === 'good' || pursuedStatuses.has(x.status)) out.pursued.push(ex);
      else if (x.feedback === 'bad' || x.status === 'passed') out.passed.push(ex);
    });
  } catch (_) { /* no calibration available yet */ }
  out.pursued = out.pursued.slice(-15);
  out.passed = out.passed.slice(-15);
  return out;
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
    if (d.minPosts) filters.number_of_posts = { min: Number(d.minPosts) };   // filter out thin/inactive accounts
    if (d.verified) filters.is_verified = true;                              // verified accounts only
    const tags = (Array.isArray(d.hashtags) ? d.hashtags : String(d.hashtags || '').split(','))
      .map((s) => s.trim().replace(/^#/, '')).filter(Boolean);
    if (tags.length) filters.hashtags = tags;                               // e.g. ["recipe","mealprep"]

    // 1) Discovery — page until we have `count` candidates (cheap: ~0.01/creator)
    const candidates = [];
    let totalMatches = null;   // how many creators match these filters overall
    for (let page = 0; candidates.length < count && page < 25; page++) {
      const body = { platform, filters, paging: { limit: Math.min(50, count - candidates.length), page } };
      if (d.nlpSearch) body.nlp_search = String(d.nlpSearch);
      const r = await icPost('/discovery/', body);
      if (totalMatches === null && typeof r.total === 'number') totalMatches = r.total;
      const accts = r.accounts || [];
      if (accts.length === 0) break;
      for (const a of accts) {
        const p = a.profile || {};
        if (p.username) candidates.push({ username: p.username, name: p.full_name || '', followers: p.followers ?? null, engagement: p.engagement_percent ?? null, photo: p.picture || '' });
      }
    }

    // 2) Dedupe against what's already in the CRM (by handle) — before enriching,
    //    so we never spend enrichment credits on a creator we already have.
    const db = getFirestore();
    const snap = await db.collection('outreach_leads').get();
    const existing = new Set();
    snap.forEach((x) => { const h = (x.data().handle || '').replace(/^@/, '').toLowerCase(); if (h) existing.add(h); });

    let skipped = 0;
    let fresh = [];
    for (const c of candidates) {
      const key = c.username.toLowerCase();
      if (existing.has(key)) { skipped++; continue; }
      existing.add(key);
      fresh.push(c);
    }

    // Learning loop: calibrate scoring + openers to Haley's past decisions.
    const calibration = await getCalibration(db);

    // 3) Score-gate (optional). When a minimum fit score is set, score creators
    //    on CHEAP data first (discovery + a ~0.03-credit bio pull), drop anyone
    //    below the threshold, then spend the 1-credit email enrichment only on
    //    the survivors — so we never buy emails for low-fit creators.
    const minFit = Math.max(0, Math.min(Number(d.minFit) || 0, 100));
    let enriched = 0, gated = 0;
    let scores = {};

    if (minFit > 0) {
      // Cheap bio pull for scoring (raw enrich ~0.03/creator).
      for (const c of fresh) {
        try {
          const r = await icPost('/creators/enrich/handle/raw/', { handle: c.username, platform });
          const rr = r.result || r;
          c.bio = String(deepFind(rr, 'biography') || '').slice(0, 300);
          c.category = String(deepFind(rr, 'category') || '');
        } catch (_) { /* score without bio if this fails */ }
      }
      scores = await scoreCreators(fresh, request.auth.token.email, calibration);
      const before = fresh.length;
      fresh = fresh.filter((c) => (scores[c.username.toLowerCase()]?.fit_score ?? 0) >= minFit);
      gated = before - fresh.length;
      // Buy emails only for the survivors.
      if (fetchEmails) {
        for (const c of fresh) {
          try {
            const e = await icPost('/creators/enrich/handle/full/', {
              handle: c.username, platform, email_required: 'preferred', include_audience_data: false,
            });
            const rr = e.result || {};
            c.email = String(rr.email || '').toLowerCase();
            c.gender = rr.gender || c.gender || '';
            c.first = rr.first_name || '';
            if (c.email || c.first) enriched++;
          } catch (_) { /* keep the lead even if email enrichment fails */ }
        }
      }
    } else {
      // Standard mode: full-enrich everyone (email + bio), then score all.
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
            c.bio = String(deepFind(rr, 'biography') || '').slice(0, 300);   // free — already in the enrich payload
            c.category = String(deepFind(rr, 'category') || '');
            if (c.email || c.first) enriched++;
          } catch (_) { /* skip enrichment failure, still add the lead */ }
        }
      }
      scores = await scoreCreators(fresh, request.auth.token.email, calibration);
    }

    // 5) Write each fresh lead with its fit score.
    let added = 0;
    for (const c of fresh) {
      const notes = [
        c.engagement != null ? `Engagement ${Number(c.engagement).toFixed(1)}%` : '',
        c.gender ? `Gender: ${c.gender}` : '',
        'via Influencers.club',
      ].filter(Boolean).join(' · ');

      await db.collection('outreach_leads').add({
        name: c.name || c.first || c.username,
        handle: '@' + c.username,
        profile_url: profileUrl(platform, c.username),
        photo: c.photo || '',
        platform: platformLabel,
        email: c.email || '',
        followers: c.followers,
        status: 'to_contact',
        last_contacted: '',
        follow_up_date: '',
        notes,
        bio: c.bio || '',
        category: c.category || '',
        fit_score: scores[c.username.toLowerCase()]?.fit_score ?? null,
        suggested_opener: scores[c.username.toLowerCase()]?.opener || '',
        source: 'influencers_club',
        created_at: FieldValue.serverTimestamp(),
        created_by: request.auth.token.email,
        updated_at: FieldValue.serverTimestamp(),
      });
      added++;
    }

    // Accurate remaining balance, read after all discovery + enrichment spend.
    const creditsLeft = await icCreditsLeft();

    return { discovered: candidates.length, added, skipped, enriched, gated, scored: Object.keys(scores).length, total_matches: totalMatches, credits_left: creditsLeft };
  },
);
