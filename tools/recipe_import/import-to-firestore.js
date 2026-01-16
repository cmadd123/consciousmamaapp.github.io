/**
 * Firestore Recipe Importer for MoMe Coach
 *
 * This script imports recipes from recipes.json into Firestore.
 * These will be "curated" recipes available to all users.
 *
 * Usage:
 * 1. First run scrape-recipes.js to create recipes.json
 * 2. Place your Firebase service account key as 'serviceAccountKey.json'
 * 3. Run: node import-to-firestore.js
 */

import { readFileSync, existsSync } from 'fs';
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const RECIPES_FILE = 'recipes.json';
const SERVICE_ACCOUNT_FILE = 'serviceAccountKey.json';

// Use a special "system" user reference for curated recipes
// This makes them available to all users
const CURATED_USER_ID = 'curated_recipes';

async function main() {
  // Check for required files
  if (!existsSync(RECIPES_FILE)) {
    console.log(`
Error: ${RECIPES_FILE} not found.
Run 'node scrape-recipes.js' first to create the recipes file.
`);
    return;
  }

  if (!existsSync(SERVICE_ACCOUNT_FILE)) {
    console.log(`
==================================================
Firebase Service Account Key Required
==================================================

To import recipes to Firestore, you need a service account key:

1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project
3. Go to Project Settings > Service Accounts
4. Click "Generate new private key"
5. Save the file as '${SERVICE_ACCOUNT_FILE}' in this directory
6. Run this script again

==================================================
`);
    return;
  }

  // Initialize Firebase
  const serviceAccount = JSON.parse(readFileSync(SERVICE_ACCOUNT_FILE, 'utf-8'));
  initializeApp({
    credential: cert(serviceAccount)
  });

  const db = getFirestore();

  // Read recipes
  const data = JSON.parse(readFileSync(RECIPES_FILE, 'utf-8'));
  const recipes = data.recipes || [];

  if (recipes.length === 0) {
    console.log('No recipes found in recipes.json');
    return;
  }

  console.log(`Importing ${recipes.length} recipes to Firestore...\n`);

  let imported = 0;
  let skipped = 0;

  for (const recipe of recipes) {
    if (!recipe.recipeName) {
      console.log(`Skipping recipe without name: ${recipe.sourceUrl}`);
      skipped++;
      continue;
    }

    try {
      // Check if recipe already exists (by name)
      const existing = await db.collection('meal')
        .where('recipe_name', '==', recipe.recipeName)
        .limit(1)
        .get();

      if (!existing.empty) {
        console.log(`Skipping duplicate: ${recipe.recipeName}`);
        skipped++;
        continue;
      }

      // Prepare recipe document
      const recipeDoc = {
        recipe_name: recipe.recipeName,
        ingredients: recipe.ingredients || [],
        CookingInstructions: Array.isArray(recipe.cookingInstructions)
          ? recipe.cookingInstructions
          : [recipe.cookingInstructions].filter(Boolean),
        image_url: recipe.imageUrl || '',
        source_url: recipe.sourceUrl || '',
        prepare_time: parseTime(recipe.prepTime),
        cooking_time: parseTime(recipe.cookTime),
        total_time: parseTime(recipe.totalTime),
        servings: recipe.servings || '',
        description: recipe.description || '',
        main_or_sides: 'main',
        meal_typ: '',
        cost: 0,
        // Mark as curated (no user_ref means it's available to all)
        is_curated: true,
        created_at: new Date(),
      };

      await db.collection('meal').add(recipeDoc);
      console.log(`Imported: ${recipe.recipeName}`);
      imported++;

    } catch (error) {
      console.error(`Error importing ${recipe.recipeName}: ${error.message}`);
      skipped++;
    }
  }

  console.log(`
==================================================
Import Complete!
==================================================
Imported:  ${imported} recipes
Skipped:   ${skipped} recipes

The recipes are now in your Firestore 'meal' collection
with is_curated=true so they're available to all users.
==================================================
`);
}

// Parse time strings like "30 mins" or "1 hour" to minutes
function parseTime(timeStr) {
  if (!timeStr) return 0;
  if (typeof timeStr === 'number') return timeStr;

  const str = timeStr.toLowerCase();
  let minutes = 0;

  // Match hours
  const hourMatch = str.match(/(\d+)\s*h/);
  if (hourMatch) {
    minutes += parseInt(hourMatch[1]) * 60;
  }

  // Match minutes
  const minMatch = str.match(/(\d+)\s*m/);
  if (minMatch) {
    minutes += parseInt(minMatch[1]);
  }

  // If just a number, assume minutes
  if (minutes === 0) {
    const numMatch = str.match(/(\d+)/);
    if (numMatch) {
      minutes = parseInt(numMatch[1]);
    }
  }

  return minutes;
}

main().catch(console.error);
