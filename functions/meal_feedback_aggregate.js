// Weekly anonymized aggregation of meal-acceptance feedback.
//
// Reads every doc in `meal_feedback` (written by the app's "How did it go?"
// prompt — see MEAL_FEEDBACK.md) and rebuilds `meal_feedback_stats`:
// one doc per (recipe × age band × meal type) cell with rating counts,
// make-again rate and the number of distinct families.
//
// Privacy:
//   • A cell is only written when it has >= K_ANONYMITY_FLOOR distinct
//     families. Smaller cells are counted in the run summary but never
//     published.
//   • No user ids, child ids, doc refs or dates are written to the output.
//     Family identity is used only in memory to count distinct families.
//   • Full rebuild each run: cells that fall below the floor (e.g. after an
//     account deletion removes that family's feedback) are deleted.
//
// Recipes are user-owned docs (each family has its own copy of
// "Mac and cheese"), so cells are keyed by a NORMALIZED recipe name, not
// by recipe doc ref.

const crypto = require('crypto');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

// Minimum distinct families before a cell is published. Do not lower
// without a privacy review.
const K_ANONYMITY_FLOOR = 20;

const RATINGS = ['loved', 'ate_some', 'refused'];
const MEAL_TYPES = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

const STATS_COLLECTION = 'meal_feedback_stats';
const META_COLLECTION = 'meal_feedback_stats_meta';
const PAGE_SIZE = 1000;
const BATCH_LIMIT = 400;

// Age bands by child age in months at the time of the meal.
function ageBand(months) {
  if (months === null || months === undefined || typeof months !== 'number' ||
      !Number.isFinite(months) || months < 0) {
    return 'unknown'; // family-level rating or child without a birthdate
  }
  if (months < 6) return 'under_6m';
  if (months < 12) return '6_11m';
  if (months < 24) return '12_23m';
  if (months < 36) return '2y';
  if (months < 48) return '3y';
  if (months < 72) return '4_5y';
  return '6y_plus';
}

// "  Mom's Mac & Cheese!! " -> "moms mac and cheese"
function normalizeRecipeName(name) {
  if (typeof name !== 'string') return '';
  return name
    .toLowerCase()
    .normalize('NFKD')
    .replace(/[̀-ͯ]/g, '') // strip accents
    .replace(/&/g, ' and ')
    .replace(/['’]/g, '')
    .replace(/[^a-z0-9]+/g, ' ')
    .trim()
    .replace(/\s+/g, ' ')
    .slice(0, 120);
}

function familyIdOf(data) {
  const ref = data.user_ref;
  if (!ref) return null;
  if (typeof ref === 'string') return ref;
  return ref.id || ref.path || null;
}

function cellIdFor(recipeKey, band, mealType) {
  return crypto.createHash('sha1')
    .update(`${recipeKey}|${band}|${mealType}`)
    .digest('hex')
    .slice(0, 32);
}

// Pure aggregation over plain feedback objects (exported for tests).
// Returns { cells: [...published], summary: {...} }.
function buildAggregates(feedbackDocs, kFloor = K_ANONYMITY_FLOOR) {
  const cells = new Map();
  const allFamilies = new Set();
  let considered = 0;
  let skipped = 0;

  for (const d of feedbackDocs) {
    const rating = d.rating;
    const family = familyIdOf(d);
    const recipeKey = normalizeRecipeName(d.recipe_name);
    if (!RATINGS.includes(rating) || !family || !recipeKey) {
      skipped++;
      continue;
    }
    const mealType = MEAL_TYPES.includes(d.meal_type) ? d.meal_type : 'Unknown';
    const band = ageBand(d.child_age_months);
    const id = cellIdFor(recipeKey, band, mealType);

    let cell = cells.get(id);
    if (!cell) {
      cell = {
        id,
        recipeKey,
        band,
        mealType,
        names: new Map(), // display-name candidate -> Set(family)
        counts: { loved: 0, ate_some: 0, refused: 0 },
        makeAgainYes: 0,
        makeAgainResponses: 0,
        families: new Set(),
      };
      cells.set(id, cell);
    }
    cell.counts[rating]++;
    if (typeof d.make_again === 'boolean') {
      cell.makeAgainResponses++;
      if (d.make_again) cell.makeAgainYes++;
    }
    cell.families.add(family);
    const display = typeof d.recipe_name === 'string' ? d.recipe_name.trim() : '';
    if (display) {
      if (!cell.names.has(display)) cell.names.set(display, new Set());
      cell.names.get(display).add(family);
    }
    allFamilies.add(family);
    considered++;
  }

  const published = [];
  let suppressed = 0;
  for (const cell of cells.values()) {
    const distinctFamilies = cell.families.size;
    if (distinctFamilies < kFloor) {
      suppressed++;
      continue;
    }
    const total = cell.counts.loved + cell.counts.ate_some + cell.counts.refused;
    // Most common spelling as display name, but only if it is used by
    // >= kFloor distinct families; otherwise fall back to the normalized key so one
    // family's idiosyncratic name ("Grandma Sue's ...") can't leak.
    let displayName = cell.recipeKey;
    let best = 0;
    for (const [name, fams] of cell.names) {
      const n = fams.size;
      if (n > best) { best = n; displayName = name; }
    }
    if (best < kFloor) displayName = cell.recipeKey;

    const round = (x) => Math.round(x * 1000) / 1000;
    published.push({
      id: cell.id,
      data: {
        recipe_key: cell.recipeKey,
        recipe_name: displayName,
        age_band: cell.band,
        meal_type: cell.mealType,
        counts: { ...cell.counts },
        total_ratings: total,
        loved_rate: total ? round(cell.counts.loved / total) : null,
        acceptance_rate: total ? round((cell.counts.loved + cell.counts.ate_some) / total) : null,
        refused_rate: total ? round(cell.counts.refused / total) : null,
        make_again_responses: cell.makeAgainResponses,
        make_again_rate: cell.makeAgainResponses
          ? round(cell.makeAgainYes / cell.makeAgainResponses)
          : null,
        distinct_families: distinctFamilies,
        k_floor: kFloor,
      },
    });
  }

  return {
    cells: published,
    summary: {
      feedback_docs_considered: considered,
      feedback_docs_skipped: skipped,
      distinct_families_total: allFamilies.size,
      cells_total: cells.size,
      cells_published: published.length,
      cells_suppressed: suppressed,
      k_floor: kFloor,
    },
  };
}

async function readAllFeedback(db) {
  const out = [];
  let last = null;
  // Paginate by doc id; select only the fields aggregation needs.
  for (;;) {
    let q = db.collection('meal_feedback')
      .select('user_ref', 'rating', 'recipe_name', 'meal_type',
        'child_age_months', 'make_again')
      .orderBy('__name__')
      .limit(PAGE_SIZE);
    if (last) q = q.startAfter(last);
    const snap = await q.get();
    if (snap.empty) break;
    for (const doc of snap.docs) out.push(doc.data());
    last = snap.docs[snap.docs.length - 1];
    if (snap.size < PAGE_SIZE) break;
  }
  return out;
}

async function runAggregation(db = getFirestore()) {
  const feedback = await readAllFeedback(db);
  const { cells, summary } = buildAggregates(feedback);
  const statsCol = db.collection(STATS_COLLECTION);

  const keep = new Set(cells.map((c) => c.id));
  const existing = await statsCol.select().get();
  const stale = existing.docs.filter((d) => !keep.has(d.id));

  let batch = db.batch();
  let ops = 0;
  const flush = async () => {
    if (ops > 0) await batch.commit();
    batch = db.batch();
    ops = 0;
  };

  for (const cell of cells) {
    batch.set(statsCol.doc(cell.id), {
      ...cell.data,
      computed_at: FieldValue.serverTimestamp(),
    });
    if (++ops >= BATCH_LIMIT) await flush();
  }
  for (const doc of stale) {
    batch.delete(doc.ref);
    if (++ops >= BATCH_LIMIT) await flush();
  }
  await flush();

  await db.collection(META_COLLECTION).doc('latest').set({
    ...summary,
    stale_cells_deleted: stale.length,
    computed_at: FieldValue.serverTimestamp(),
  });

  console.log('aggregateMealFeedback:', JSON.stringify({ ...summary, stale_cells_deleted: stale.length }));
  return summary;
}

exports.aggregateMealFeedback = onSchedule(
  {
    schedule: 'every monday 04:00',
    timeZone: 'America/Chicago',
    timeoutSeconds: 540,
    memory: '1GiB',
  },
  async () => {
    await runAggregation();
  }
);

// Account deletion: remove all of a user's meal_feedback docs.
// Called from onUserDeleted in index.js.
async function deleteMealFeedbackForUser(uid, db = getFirestore()) {
  const userRef = db.collection('users').doc(uid);
  let deleted = 0;
  for (;;) {
    const snap = await db.collection('meal_feedback')
      .where('user_ref', '==', userRef)
      .limit(BATCH_LIMIT)
      .get();
    if (snap.empty) break;
    const batch = db.batch();
    snap.docs.forEach((d) => batch.delete(d.ref));
    await batch.commit();
    deleted += snap.size;
    if (snap.size < BATCH_LIMIT) break;
  }
  return deleted;
}

exports.deleteMealFeedbackForUser = deleteMealFeedbackForUser;

// Exposed for local tests only (not deployed — not exported from index.js).
exports._internal = {
  K_ANONYMITY_FLOOR,
  ageBand,
  normalizeRecipeName,
  buildAggregates,
  cellIdFor,
};
