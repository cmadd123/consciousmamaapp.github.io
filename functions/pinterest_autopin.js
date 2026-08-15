// Pinterest auto-pin engine — drips branded pins to MomRise's own boards on
// a schedule, driving organic traffic + installs. Implements the "programmatic
// pinning at scale" idea from MOMRISE_TRAFFIC_BRIEF.md, ToS-safely (a steady
// drip, never a flood).
//
// ── Design ────────────────────────────────────────────────────────────────
//   * Config lives in Firestore doc `config/pinterest` so it can be tuned /
//     switched on WITHOUT a redeploy:
//       {
//         enabled: false,                 // master switch (starts off)
//         boards: [ { id, slug, name } ], // your own board IDs (rotated)
//         pins_per_run: 2,                // guardrail: pins created per run
//         min_days_between_repins: 30,    // don't re-pin the same recipe too soon
//         access_token: "",               // cached; refreshed automatically
//         access_token_expires_at: 0,     // epoch ms
//         board_cursor: 0                 // round-robin pointer
//       }
//   * Secrets (Secret Manager, set before deploy):
//       PINTEREST_APP_ID       (the app's client id)
//       PINTEREST_APP_SECRET   (the app's client secret)
//       PINTEREST_REFRESH_TOKEN(from the one-time OAuth grant)
//   * Content source: curated recipes (meal where is_curated == true) that
//     already have a branded pin image (magazine_pin_url). Each pin links to
//     the recipe's /r/{slug}/ page with ?src=pinterest tracking.
//
// The function is a NO-OP until config.enabled === true, so it's safe to
// deploy ahead of go-live. Nothing is pinned until you flip the switch.
//
// See PINTEREST_AUTOPIN.md for the full activation checklist.

const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

const PINTEREST_APP_ID = defineSecret('PINTEREST_APP_ID');
const PINTEREST_APP_SECRET = defineSecret('PINTEREST_APP_SECRET');
const PINTEREST_REFRESH_TOKEN = defineSecret('PINTEREST_REFRESH_TOKEN');

const API = 'https://api.pinterest.com/v5';
const CONFIG_REF = () => getFirestore().doc('config/pinterest');
const ADMIN_EMAILS = ['collinjmaddox@gmail.com', 'brennanmaddox27@gmail.com', 'haley.hostetter@gmail.com'];

// ── OAuth: exchange the long-lived refresh token for a short-lived access
// token, caching it in the config doc until ~5 min before it expires.
async function getAccessToken(cfg) {
  const now = Date.now();
  if (cfg.access_token && cfg.access_token_expires_at && cfg.access_token_expires_at - 300000 > now) {
    return cfg.access_token;
  }
  const basic = Buffer.from(`${PINTEREST_APP_ID.value()}:${PINTEREST_APP_SECRET.value()}`).toString('base64');
  const res = await fetch(`${API}/oauth/token`, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${basic}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      grant_type: 'refresh_token',
      refresh_token: PINTEREST_REFRESH_TOKEN.value(),
    }),
  });
  const data = await res.json();
  if (!res.ok || !data.access_token) {
    throw new Error(`Pinterest token refresh failed (${res.status}): ${JSON.stringify(data).slice(0, 300)}`);
  }
  const expiresAt = now + (Number(data.expires_in || 3600) * 1000);
  await CONFIG_REF().set({
    access_token: data.access_token,
    access_token_expires_at: expiresAt,
  }, { merge: true });
  return data.access_token;
}

// ── Compose a keyword-rich pin from a recipe. Pinterest search leans on the
// title + description, so we pack in intent keywords, not marketing fluff.
function buildPin(recipe, slug, board) {
  const name = recipe.recipe_name || 'Easy family recipe';
  const type = (recipe.meal_typ || '').toLowerCase();
  const typeWord = /breakfast|lunch|dinner|dessert|snack|side/.test(type) ? type : 'dinner';
  const title = name.slice(0, 100);
  const description = [
    `${name} — an easy family ${typeWord} the kids will actually eat.`,
    `Save it and plan your whole week free in the MomRise app: meal plans + auto grocery list.`,
    `#familydinner #mealplanning #easyrecipes #kidfriendly #whatsfordinner`,
  ].join(' ').slice(0, 490);
  const link = `https://momrise.app/r/${slug}/?src=pinterest&board=${encodeURIComponent(board.slug || '')}`;
  return {
    board_id: board.id,
    title,
    description,
    link,
    media_source: { source_type: 'image_url', url: recipe.magazine_pin_url },
  };
}

async function createPin(accessToken, pin) {
  const res = await fetch(`${API}/pins`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(pin),
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(`Pinterest createPin failed (${res.status}): ${JSON.stringify(data).slice(0, 300)}`);
  }
  return data; // { id, ... }
}

// ── Core: pin up to `limit` eligible recipes, rotating boards. Returns a
// small summary. Shared by the schedule + the manual test trigger.
async function runPinBatch(limit) {
  const db = getFirestore();
  const cfgSnap = await CONFIG_REF().get();
  const cfg = cfgSnap.exists ? cfgSnap.data() : {};

  if (cfg.enabled !== true) return { skipped: 'disabled' };
  const boards = Array.isArray(cfg.boards) ? cfg.boards.filter((b) => b && b.id) : [];
  if (boards.length === 0) return { skipped: 'no_boards_configured' };

  const perRun = Math.max(1, Math.min(limit || cfg.pins_per_run || 2, 10)); // hard cap 10/run
  const minDays = Number(cfg.min_days_between_repins || 30);
  const cutoff = Date.now() - minDays * 86400000;

  // Candidates: curated recipes with a branded pin image. Sort oldest-pinned
  // first (never-pinned first) in memory — the curated set is small.
  const snap = await db.collection('meal').where('is_curated', '==', true).get();
  const candidates = snap.docs
    .map((d) => ({ ref: d.ref, id: d.id, data: d.data() }))
    .filter((x) => x.data.magazine_pin_url && x.data.recipe_name)
    .filter((x) => {
      const last = x.data.last_pinned_at?.toMillis?.() || 0;
      return last <= cutoff;
    })
    .sort((a, b) => (a.data.last_pinned_at?.toMillis?.() || 0) - (b.data.last_pinned_at?.toMillis?.() || 0));

  if (candidates.length === 0) return { pinned: 0, note: 'no eligible recipes' };

  const accessToken = await getAccessToken(cfgSnap.exists ? cfg : {});
  let cursor = Number(cfg.board_cursor || 0);
  const results = [];

  for (const c of candidates.slice(0, perRun)) {
    const board = pickBoard(boards, bucketRecipe(c.data), cursor);
    const slug = slugFor(c.data, c.id);
    try {
      const pin = buildPin(c.data, slug, board);
      const created = await createPin(accessToken, pin);
      await c.ref.set({
        last_pinned_at: FieldValue.serverTimestamp(),
        pin_count: FieldValue.increment(1),
        last_pin_id: created.id || null,
        last_pin_board: board.id,
      }, { merge: true });
      results.push({ recipe: c.data.recipe_name, board: board.slug || board.id, pin_id: created.id });
      cursor++;
    } catch (e) {
      results.push({ recipe: c.data.recipe_name, error: String(e.message || e) });
      // keep going; a single failure shouldn't stop the batch
    }
  }

  await CONFIG_REF().set({ board_cursor: cursor, last_run_at: FieldValue.serverTimestamp() }, { merge: true });
  return { pinned: results.filter((r) => r.pin_id).length, results };
}

// Coarse meal-type bucket (matches scripts/generate-meal-index.js). Used to
// route each recipe to a board that accepts its type. Reads meal_typ first,
// then the name (most curated recipes have no explicit meal_typ).
function bucketRecipe(recipe) {
  const s = `${recipe.meal_typ || ''} ${recipe.recipe_name || ''}`.toLowerCase();
  if (/dessert|cookie|brownie|browkie|blondie|\bcake\b|cupcake|ice cream|\bpie\b|cheesecake|\bbars?\b|fudge|truffle|oreo|donut|doughnut|pop.?tart|cinnamon roll|frosting|candy|\bballs?\b/.test(s)) return 'Dessert';
  if (/breakfast|pancake|waffle|muffin|oatmeal|granola|mcgriddle|hash brown|egg bake|french toast|smoothie/.test(s)) return 'Breakfast';
  if (/snack|nachos|\bbites\b|queso|dip|popcorn/.test(s)) return 'Snack';
  if (/lunch|sandwich|wrap/.test(s)) return 'Lunch';
  return 'Dinner';
}

// Pick a board that accepts this recipe's type. A board with no `types` (or an
// empty list) is a general board that takes anything. Falls back to all boards
// if nothing matches, so a pin never gets stuck.
function pickBoard(boards, bucket, cursor) {
  const eligible = boards.filter((b) => !Array.isArray(b.types) || b.types.length === 0 || b.types.includes(bucket));
  const pool = eligible.length ? eligible : boards;
  return pool[cursor % pool.length];
}

// Mirror of the recipe-page generator's slug logic so links match /r/{slug}/.
function kebab(s) {
  return String(s || '').toLowerCase().replace(/[^\w\s-]/g, '').trim()
    .replace(/\s+/g, '-').replace(/-+/g, '-').slice(0, 60);
}
function slugFor(recipe, docId) {
  const shortId = String(docId).slice(-6);
  return `${kebab(recipe.recipe_name)}-${shortId}` || `recipe-${shortId}`;
}

const SECRETS = [PINTEREST_APP_ID, PINTEREST_APP_SECRET, PINTEREST_REFRESH_TOKEN];

// Scheduled drip. Three times a day on weekdays = a steady, ToS-safe cadence.
// Actual pins/run is governed by config.pins_per_run (default 2).
exports.pinterestAutoPin = onSchedule(
  { schedule: '0 9,13,17 * * 1-5', timeZone: 'America/New_York', secrets: SECRETS },
  async () => {
    const summary = await runPinBatch();
    console.log('[pinterest-autopin]', JSON.stringify(summary));
  },
);

// Manual trigger for testing once credentials are in place (admin-gated).
// Call with { count } to pin a specific number now.
exports.pinterestTestPin = onCall({ secrets: SECRETS }, async (request) => {
  const email = (request.auth?.token?.email || '').toLowerCase();
  if (!ADMIN_EMAILS.includes(email)) throw new HttpsError('permission-denied', 'Admin only');
  const count = Math.max(1, Math.min(Number(request.data?.count || 1), 5));
  return runPinBatch(count);
});
