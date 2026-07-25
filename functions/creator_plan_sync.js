// Bridge web-published meal plans into the app's read model.
//
// The web creator dashboard writes a rich, slots-based plan to the
// `creator_products` collection. The mobile app instead reads
// `creator_content` (by creator_code, type=='meal_plan', is_active==true).
// The two were never connected, so web-published plans were invisible in
// the app. This maps a published `creator_products` doc into a
// `creator_content` doc in the exact shape publishMealPlanToFollowers writes.
//
// Idempotent: the bridged creator_content doc stores `source_product_id`, so
// re-publishing updates the same doc. Unpublishing / deleting deactivates it.

const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { onRequest } = require('firebase-functions/v2/https');
const { defineString } = require('firebase-functions/params');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

const backfillSecret = defineString('BACKFILL_SECRET');
const MEAL_KEYS = ['breakfast', 'lunch', 'dinner', 'snack'];

// Map one creator_products doc into creator_content. Returns meals synced.
async function _syncProduct(db, productId, after) {
  const existingSnap = await db
    .collection('creator_content')
    .where('source_product_id', '==', productId)
    .limit(1)
    .get();
  const existingRef = existingSnap.empty ? null : existingSnap.docs[0].ref;

  if (!after || after.type !== 'meal_plan' || after.status !== 'published') {
    if (existingRef) await existingRef.update({ is_active: false });
    return 0;
  }

  const creatorRef = after.creator_ref;
  if (!creatorRef) return 0;
  let creatorName = '';
  try {
    const cSnap = await creatorRef.get();
    creatorName = cSnap.exists ? cSnap.data().name || '' : '';
  } catch (_) {
    /* non-fatal */
  }

  const slots = after.slots || {};
  const weekData = {};
  const dayLabels = {};
  let totalMeals = 0;

  for (const [slotKey, recipesRaw] of Object.entries(slots)) {
    const recipes = Array.isArray(recipesRaw) ? recipesRaw : [];
    if (recipes.length === 0) continue;
    const us = slotKey.indexOf('_');
    if (us < 0) continue;
    const dayIdx = parseInt(slotKey.slice(0, us), 10);
    const mealKey = slotKey.slice(us + 1);
    if (isNaN(dayIdx) || !MEAL_KEYS.includes(mealKey)) continue;

    const dayKey = `day_${dayIdx + 1}`;
    dayLabels[dayKey] = `Day ${dayIdx + 1}`;

    // Web slots store each recipe as {recipe_id, recipe_name, image_url, role}
    // where role is lowercase 'entree'|'side'|'dessert'. (Earlier code read
    // r.recipe_type / r.id, which never matched — so sides/desserts were
    // dropped and ingredients/instructions/cost never synced.)
    const roleOf = (r) => (r.role || r.recipe_type || '').toLowerCase();
    const idOf = (r) => r.recipe_id || r.id;
    const primary =
      recipes.find((r) => roleOf(r) === 'entree') || recipes[0];
    const sides = recipes.filter((r) => roleOf(r) === 'side');
    const desserts = recipes.filter((r) => roleOf(r) === 'dessert');

    const entry = { name: primary.recipe_name || 'Planned' };
    if (primary.image_url) entry.image_url = primary.image_url;

    const primaryId = idOf(primary);
    if (primaryId) {
      try {
        const mealDoc = await db.collection('meal').doc(primaryId).get();
        if (mealDoc.exists) {
          const m = mealDoc.data();
          if (Array.isArray(m.ingredients) && m.ingredients.length) {
            entry.ingredients = m.ingredients;
          }
          if (
            Array.isArray(m.CookingInstructions) &&
            m.CookingInstructions.length
          ) {
            entry.instructions = m.CookingInstructions;
          }
          if (m.source_url) entry.source_url = m.source_url;
          if (m.estimated_cost > 0) entry.estimated_cost = m.estimated_cost;
          if (!entry.image_url && m.image_url) entry.image_url = m.image_url;
        }
      } catch (_) {
        /* non-fatal */
      }
    }

    if (sides.length) {
      entry.sides = sides.map((r) => ({
        name: r.recipe_name || '',
        image_url: r.image_url || '',
      }));
    }
    if (desserts.length) {
      entry.desserts = desserts.map((r) => ({
        name: r.recipe_name || '',
        image_url: r.image_url || '',
      }));
    }

    if (!weekData[dayKey]) weekData[dayKey] = {};
    weekData[dayKey][mealKey] = entry;
    totalMeals++;
  }

  if (totalMeals === 0) {
    if (existingRef) await existingRef.update({ is_active: false });
    return 0;
  }

  weekData._day_labels = dayLabels;
  weekData._total_days = Object.keys(weekData).filter((k) =>
    k.startsWith('day_'),
  ).length;
  weekData._total_meals = totalMeals;

  // The app shows the creator's latest active plan — deactivate the others.
  // Guard on a non-empty creator_code: an empty code would match every
  // no-code plan across ALL creators and wrongly deactivate them.
  if (after.creator_code) {
    const activeSnap = await db
      .collection('creator_content')
      .where('creator_code', '==', after.creator_code)
      .where('type', '==', 'meal_plan')
      .where('is_active', '==', true)
      .get();
    const batch = db.batch();
    activeSnap.forEach((d) => {
      if (!existingRef || d.ref.path !== existingRef.path) {
        batch.update(d.ref, { is_active: false });
      }
    });
    await batch.commit();
  }

  const contentData = {
    creator_ref: creatorRef,
    creator_code: after.creator_code || '',
    creator_name: creatorName,
    type: 'meal_plan',
    title: after.title || 'Meal Plan',
    description: after.description || '',
    data: weekData,
    is_active: true,
    is_free: true,
    price: 0,
    download_count: 0,
    published_at: after.published_at || FieldValue.serverTimestamp(),
    source_product_id: productId,
  };

  if (existingRef) {
    await existingRef.update(contentData);
  } else {
    contentData.created_at = FieldValue.serverTimestamp();
    await db.collection('creator_content').add(contentData);
  }
  return totalMeals;
}

// Live trigger: sync on every creator_products write.
exports.syncCreatorPlanToContent = onDocumentWritten(
  'creator_products/{id}',
  async (event) => {
    const db = getFirestore();
    const synced = await _syncProduct(
      db,
      event.params.id,
      event.data?.after?.data(),
    );
    if (synced > 0) {
      console.log(
        `[plan-sync] creator_products/${event.params.id} -> creator_content (${synced} meals)`,
      );
    }
  },
);

// One-time backfill: re-sync every already-published plan. Secret-gated.
// Call: /backfillCreatorPlans?secret=<BACKFILL_SECRET from functions/.env>
exports.backfillCreatorPlans = onRequest(async (request, response) => {
  const provided = String(request.query.secret || '');
  const expected = backfillSecret.value();
  if (!expected || provided !== expected) {
    response.status(403).send('Forbidden');
    return;
  }
  try {
    const db = getFirestore();
    const snap = await db
      .collection('creator_products')
      .where('status', '==', 'published')
      .get();
    let plans = 0;
    let mealsSynced = 0;
    for (const doc of snap.docs) {
      const data = doc.data();
      if (data.type !== 'meal_plan') continue;
      plans++;
      mealsSynced += await _syncProduct(db, doc.id, data);
    }
    console.log(`[plan-backfill] ${plans} plans, ${mealsSynced} meals synced`);
    response.json({ ok: true, plans, mealsSynced });
  } catch (e) {
    console.error('backfillCreatorPlans failed', e);
    response.status(500).json({ ok: false, error: e.message });
  }
});
