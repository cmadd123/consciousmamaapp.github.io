const functions = require("firebase-functions");
const admin = require("firebase-admin");
const db = admin.firestore();

/**
 * Cloud Function to verify and fix meal tags when a meal is created.
 * Ensures all meals have at least one category tag (Breakfast, Lunch, Dinner, etc.)
 * This is a redundant safety check in case the frontend auto-detection fails.
 */
exports.verifyMealTags = functions.firestore
  .document("meal/{mealId}")
  .onCreate(async (snap, context) => {
    const mealData = snap.data();
    const mealTyp = mealData.mealTyp;

    // If mealTyp is already present and not empty, no action needed
    if (mealTyp && mealTyp.trim().length > 0) {
      console.log(`Meal ${context.params.mealId} already has mealTyp: ${mealTyp}`);
      return null;
    }

    // mealTyp is missing or empty - need to auto-detect
    console.log(`Meal ${context.params.mealId} missing mealTyp, auto-detecting...`);

    const recipeName = (mealData.recipeName || "").toLowerCase();
    const detectedCategories = [];

    // Keywords for each category (same as frontend)
    const breakfastKeywords = [
      "breakfast",
      "pancake",
      "waffle",
      "oatmeal",
      "cereal",
      "toast",
      "eggs",
      "bacon",
      "sausage",
      "brunch",
      "muffin",
      "bagel",
      "croissant",
      "french toast",
      "scrambled",
      "omelet",
      "smoothie bowl",
    ];
    const lunchKeywords = [
      "lunch",
      "sandwich",
      "wrap",
      "salad",
      "soup",
      "panini",
      "burger",
      "sub",
      "hoagie",
    ];
    const dinnerKeywords = [
      "dinner",
      "roast",
      "steak",
      "chicken breast",
      "pork chop",
      "salmon",
      "pasta",
      "casserole",
      "curry",
      "stir fry",
      "grilled",
      "baked chicken",
      "pot roast",
      "lasagna",
      "enchilada",
      "risotto",
    ];
    const sideKeywords = [
      "side",
      "sides",
      "side dish",
      "fries",
      "mashed potato",
      "coleslaw",
      "green beans",
      "corn",
      "rice",
      "roasted vegetables",
    ];
    const snackKeywords = [
      "snack",
      "appetizer",
      "dip",
      "chip",
      "cracker",
      "finger food",
      "bite",
      "ball",
    ];
    const dessertKeywords = [
      "dessert",
      "cake",
      "cookie",
      "brownie",
      "pie",
      "ice cream",
      "chocolate",
      "sweet",
      "pudding",
      "tart",
      "cupcake",
      "cheesecake",
      "candy",
      "fudge",
      "truffle",
    ];

    // Check for keyword matches
    if (breakfastKeywords.some((keyword) => recipeName.includes(keyword))) {
      detectedCategories.push("Breakfast");
    }
    if (lunchKeywords.some((keyword) => recipeName.includes(keyword))) {
      detectedCategories.push("Lunch");
    }
    if (dinnerKeywords.some((keyword) => recipeName.includes(keyword))) {
      detectedCategories.push("Dinner");
    }
    if (sideKeywords.some((keyword) => recipeName.includes(keyword))) {
      detectedCategories.push("Side");
    }
    if (snackKeywords.some((keyword) => recipeName.includes(keyword))) {
      detectedCategories.push("Snacks");
    }
    if (dessertKeywords.some((keyword) => recipeName.includes(keyword))) {
      detectedCategories.push("Desserts");
    }

    // If no categories detected, default to Dinner (most common)
    if (detectedCategories.length === 0) {
      detectedCategories.push("Dinner");
      console.log(
        `No keywords matched for "${recipeName}", defaulting to Dinner`
      );
    }

    const newMealTyp = detectedCategories.join(",");
    console.log(
      `Auto-detected categories for meal ${context.params.mealId}: ${newMealTyp}`
    );

    // Update the meal document with detected categories
    try {
      await snap.ref.update({
        mealTyp: newMealTyp,
      });
      console.log(`Successfully updated meal ${context.params.mealId} with mealTyp: ${newMealTyp}`);
    } catch (error) {
      console.error(`Error updating meal ${context.params.mealId}:`, error);
    }

    return null;
  });
