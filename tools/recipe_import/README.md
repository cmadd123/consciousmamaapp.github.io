# Recipe Import Tool for MoMe Coach

This tool helps you import recipes from Pinterest into the MoMe Coach app.

## Quick Start

### Step 1: Install dependencies
```bash
cd tools/recipe_import
npm install
```

### Step 2: Get recipe URLs from Pinterest

Since your Pinterest board is private, you'll need to manually collect the source URLs:

1. Open your Pinterest board: https://www.pinterest.com/randcstationery/recipes-for-app/
2. For each pin:
   - Click on the pin to open it
   - Look for the "Visit" or source link button
   - Copy the actual recipe URL (e.g., allrecipes.com, foodnetwork.com, etc.)
3. Paste each URL into `recipe-urls.txt`, one per line

### Step 3: Scrape recipes
```bash
npm run scrape
```

This will create `recipes.json` with all the recipe data.

### Step 4: Import to Firestore

1. Get your Firebase service account key:
   - Go to Firebase Console > Project Settings > Service Accounts
   - Click "Generate new private key"
   - Save as `serviceAccountKey.json` in this folder

2. Run the import:
```bash
npm run import
```

## Troubleshooting

### Some recipes fail to scrape
The recipe-scraper library supports most major recipe sites, but not all. For failed recipes, you can:
1. Manually add them to `recipes.json`
2. Use the app's "Add Recipe" feature to enter them manually

### Recipe format
If you need to manually create recipes, use this format in `recipes.json`:

```json
{
  "recipes": [
    {
      "recipeName": "Chicken Dinner",
      "sourceUrl": "https://example.com/chicken",
      "imageUrl": "https://example.com/chicken.jpg",
      "ingredients": [
        "2 lbs chicken",
        "1 cup rice",
        "Salt and pepper"
      ],
      "cookingInstructions": [
        "Preheat oven to 375F",
        "Season chicken",
        "Bake for 45 minutes"
      ],
      "prepTime": "15 mins",
      "cookTime": "45 mins",
      "servings": "4",
      "success": true
    }
  ]
}
```

## Files

- `recipe-urls.txt` - Input: list of recipe URLs to scrape
- `recipes.json` - Output: scraped recipe data
- `serviceAccountKey.json` - Your Firebase credentials (don't commit this!)
- `scrape-recipes.js` - Scraper script
- `import-to-firestore.js` - Firestore import script
