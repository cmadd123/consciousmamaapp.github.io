// Build the meal-idea generator's dataset from the already-published recipe
// pages. Parses the Recipe JSON-LD out of each r/{slug}/index.html and emits
// a compact, filterable index at meal-ideas/recipes.json.
//
// Secret-free (reads committed HTML, not Firestore) so it runs in CI. Keeps
// the tool automatically in sync with whatever recipes are published.
//
//   node scripts/generate-meal-index.js

const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const recipesDir = path.join(repoRoot, 'r');
const outDir = path.join(repoRoot, 'meal-ideas');
const outFile = path.join(outDir, 'recipes.json');

function isoToMin(v) {
  const m = String(v || '').match(/^PT(?:(\d+)H)?(?:(\d+)M)?$/);
  if (!m) return 0;
  return (parseInt(m[1] || 0, 10) * 60) + parseInt(m[2] || 0, 10);
}

// Normalize into a coarse meal-type bucket the UI filters on. Most curated
// recipes have no explicit category (schema defaults to "Main Course"), so we
// also read the recipe name as a signal. Order matters: dessert/breakfast
// cues win over the Dinner default.
function bucket(cat, name) {
  const s = `${cat || ''} ${name || ''}`.toLowerCase();
  if (/dessert|cookie|brownie|browkie|blondie|\bcake\b|cupcake|ice cream|\bpie\b|cheesecake|\bbars?\b|fudge|truffle|oreo|donut|doughnut|pop.?tart|cinnamon roll|frosting|candy|\bballs?\b|protein ball/.test(s)) return 'Dessert';
  if (/breakfast|pancake|waffle|muffin|oatmeal|granola|mcgriddle|hash brown|egg bake|french toast|smoothie/.test(s)) return 'Breakfast';
  if (/snack|nachos|\bbites\b|queso|dip|popcorn/.test(s)) return 'Snack';
  if (/lunch|sandwich|wrap/.test(s)) return 'Lunch';
  if (/\bside\b|asparagus|fries/.test(s)) return 'Side';
  return 'Dinner';
}

function firstJsonLd(html) {
  // Grab each ld+json block; return the first that is a Recipe.
  const re = /<script type="application\/ld\+json">([\s\S]*?)<\/script>/gi;
  let m;
  while ((m = re.exec(html)) !== null) {
    try {
      const obj = JSON.parse(m[1].replace(/<\\\/script/gi, '</script'));
      if (obj && obj['@type'] === 'Recipe') return obj;
    } catch { /* skip malformed block */ }
  }
  return null;
}

const dirs = fs.existsSync(recipesDir)
  ? fs.readdirSync(recipesDir, { withFileTypes: true }).filter((d) => d.isDirectory()).map((d) => d.name)
  : [];

const items = [];
for (const slug of dirs) {
  const file = path.join(recipesDir, slug, 'index.html');
  if (!fs.existsSync(file)) continue;
  const r = firstJsonLd(fs.readFileSync(file, 'utf8'));
  if (!r || !r.name) continue;
  const prep = isoToMin(r.prepTime);
  const cook = isoToMin(r.cookTime);
  items.push({
    slug,
    name: r.name,
    image: Array.isArray(r.image) ? (r.image[0] || '') : (r.image || ''),
    type: bucket(r.recipeCategory, r.name),
    minutes: prep + cook,
    ingredients: Array.isArray(r.recipeIngredient) ? r.recipeIngredient.length : 0,
  });
}

// Stable sort by name so the committed file has a deterministic diff.
items.sort((a, b) => a.name.localeCompare(b.name));

fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(outFile, JSON.stringify(items, null, 0) + '\n', 'utf8');
console.log(`Wrote meal-ideas/recipes.json with ${items.length} recipes.`);
const byType = items.reduce((a, i) => ((a[i.type] = (a[i.type] || 0) + 1), a), {});
console.log('By type:', JSON.stringify(byType));
