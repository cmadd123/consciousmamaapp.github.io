// Bridge web-published meal plans into the app's read model.
//
// The web creator dashboard writes a rich, slots-based plan to the
// `creator_products` collection. The mobile app instead reads
// `creator_content` (by creator_code, type=='meal_plan', is_active==true).
// The two were never connected, so web-published plans were invisible in
// the app. This trigger maps a published `creator_products` doc into a
// `creator_content` doc in the exact shape publishMealPlanToFollowers writes.
//
// Idempotent: the bridged creator_content doc stores `source_product_id`, so
// re-publishing updates the same doc instead of creating duplicates.
// Unpublishing / deleting deactivates the bridged doc.

const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

const MEAL_KEYS = ['breakfast', 'lunch', 'dinner', 'snack'];

exports.syncCreatorPlanToContent = onDocumentWritten(
  'creator_products/{id}',
  async (event) => {
    const db = getFirestore();
    const productId = event.params.id;
    const after = event.data?.after?.data();

    // Any existing bridged creator_content doc for this product.
    const existingSnap = await db
      .collection('creator_content')
      .where('source_product_id', '==', productId)
      .limit(1)
      .get();
    const existingRef = existingSnap.empty ? null : existingSnap.docs[0].ref;

    // Deleted, not a meal plan, or not published → deactivate the bridge.
    if (!after || after.type !== 'meal_plan' || after.status !== 'published') {
      if (existingRef) await existingRef.update({ is_active: false });
      return;
    }

    const creatorRef = after.creator_ref;
    if (!creatorRef) return;
    let creatorName = '';
    try {
      const cSnap = await creatorRef.get();
      creatorName = cSnap.exists ? cSnap.data().name || '' : '';
    } catch (_) {
      /* non-fatal */
    }

    // Map slots → weekData (day_N → mealKey → entry).
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

      const primary =
        recipes.find((r) => (r.recipe_type || '') === 'Entree') || recipes[0];
      const sides = recipes.filter((r) => (r.recipe_type || '') === 'Side');
      const desserts = recipes.filter(
        (r) => (r.recipe_type || '') === 'Dessert',
      );

      const entry = { name: primary.recipe_name || 'Planned' };
      if (primary.image_url) entry.image_url = primary.image_url;

      // Enrich the primary from its meal doc so the imported plan carries
      // ingredients / instructions / cost, matching an app-published plan.
      if (primary.id) {
        try {
          const mealDoc = await db.collection('meal').doc(primary.id).get();
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
      return;
    }

    weekData._day_labels = dayLabels;
    weekData._total_days = Object.keys(weekData).filter((k) =>
      k.startsWith('day_'),
    ).length;
    weekData._total_meals = totalMeals;

    // The app shows the creator's latest active plan — deactivate the others.
    const activeSnap = await db
      .collection('creator_content')
      .where('creator_code', '==', after.creator_code || '')
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

    console.log(
      `[plan-sync] synced creator_products/${productId} -> creator_content (${totalMeals} meals)`,
    );
  },
);
