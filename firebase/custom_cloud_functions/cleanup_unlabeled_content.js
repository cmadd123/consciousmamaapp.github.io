const functions = require("firebase-functions");
const admin = require("firebase-admin");
const db = admin.firestore();

/**
 * Cloud Function to delete ALL recipes, saved days, and meal templates for the authenticated user
 */
exports.cleanupUnlabeledContent = functions.https.onCall(async (data, context) => {
  // Require authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to clean up content."
    );
  }

  const userId = context.auth.uid;
  const results = {
    recipesDeleted: 0,
    savedDaysDeleted: 0,
    templatesDeleted: 0,
  };

  try {
    // 1. Delete ALL recipes (meal collection)
    const recipesSnapshot = await db
      .collection("meal")
      .where("user_ref", "==", db.doc(`users/${userId}`))
      .get();

    const recipeDeletePromises = [];
    recipesSnapshot.forEach((doc) => {
      const data = doc.data();
      console.log(`Deleting recipe: ${doc.id} - ${data.recipeName || "No name"}`);
      recipeDeletePromises.push(doc.ref.delete());
      results.recipesDeleted++;
    });

    await Promise.all(recipeDeletePromises);

    // 2. Delete ALL saved days (favourit_meal collection)
    const savedDaysSnapshot = await db
      .collection("favourit_meal")
      .where("user_ref", "==", db.doc(`users/${userId}`))
      .get();

    const savedDayDeletePromises = [];
    savedDaysSnapshot.forEach((doc) => {
      const data = doc.data();
      console.log(`Deleting saved day: ${doc.id} - ${data.name || "No name"}`);
      savedDayDeletePromises.push(doc.ref.delete());
      results.savedDaysDeleted++;
    });

    await Promise.all(savedDayDeletePromises);

    // 3. Delete ALL meal templates (meal_combo collection)
    const templatesSnapshot = await db
      .collection("meal_combo")
      .where("user_ref", "==", db.doc(`users/${userId}`))
      .get();

    const templateDeletePromises = [];
    templatesSnapshot.forEach((doc) => {
      const data = doc.data();
      console.log(`Deleting template: ${doc.id} - ${data.name || "No name"}`);
      templateDeletePromises.push(doc.ref.delete());
      results.templatesDeleted++;
    });

    await Promise.all(templateDeletePromises);

    console.log(`Cleanup complete for user ${userId}:`, results);
    return {
      success: true,
      ...results,
      message: `Deleted ${results.recipesDeleted} recipes, ${results.savedDaysDeleted} saved days, and ${results.templatesDeleted} templates.`,
    };

  } catch (error) {
    console.error("Error during cleanup:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});
