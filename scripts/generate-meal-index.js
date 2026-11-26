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

// ── Static, crawlable copy of the ideas ────────────────────────────────
// The interactive tool renders from recipes.json in the browser, but most AI
// crawlers (GPTBot, ClaudeBot, PerplexityBot) don't run JavaScript — to them
// the page was an empty grid. Write a plain-HTML list of every idea, grouped
// by meal type and cook time, between the STATIC-IDEAS markers in
// meal-ideas/index.html. Useful to people too (browse without filtering).
const pageFile = path.join(outDir, 'index.html');
const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const TYPE_ORDER = ['Dinner', 'Breakfast', 'Lunch', 'Snack', 'Side', 'Dessert'];
const TIME_BANDS = [
  { label: 'Ready in 20 minutes or less', test: (m) => m > 0 && m <= 20 },
  { label: '21–30 minutes', test: (m) => m > 20 && m <= 30 },
  { label: '31–45 minutes', test: (m) => m > 30 && m <= 45 },
  { label: 'Over 45 minutes', test: (m) => m > 45 },
  { label: 'Time not listed', test: (m) => !m },
];
function renderStatic(list) {
  const out = [];
  out.push('<section class="all-ideas" id="all-ideas">');
  out.push(`  <h2>All ${list.length} meal ideas, by meal and cook time</h2>`);
  for (const type of TYPE_ORDER) {
    const ofType = list.filter((i) => i.type === type);
    if (!ofType.length) continue;
    out.push(`  <h3>${type} ideas (${ofType.length})</h3>`);
    for (const band of TIME_BANDS) {
      const inBand = ofType.filter((i) => band.test(i.minutes)).sort((a, b) => (a.minutes - b.minutes) || a.name.localeCompare(b.name));
      if (!inBand.length) continue;
      out.push(`  <h4>${band.label}</h4>`);
      out.push('  <ul>');
      for (const i of inBand) {
        const meta = [i.minutes ? `${i.minutes} min` : '', i.ingredients ? `${i.ingredients} ingredients` : ''].filter(Boolean).join(' · ');
        out.push(`    <li><a href="/r/${esc(i.slug)}/">${esc(i.name)}</a>${meta ? ` <span>— ${meta}</span>` : ''}</li>`);
      }
      out.push('  </ul>');
    }
  }
  out.push('</section>');
  return out.join('\n');
}
if (fs.existsSync(pageFile)) {
  const page = fs.readFileSync(pageFile, 'utf8');
  const re = /(<!-- STATIC-IDEAS:START[^>]*-->)[\s\S]*?(\s*<!-- STATIC-IDEAS:END -->)/;
  if (re.test(page)) {
    const next = page.replace(re, (m, start, end) => `${start}\n${renderStatic(items)}${end}`);
    if (next !== page) fs.writeFileSync(pageFile, next, 'utf8');
    console.log('Wrote static idea list into meal-ideas/index.html');
  } else {
    console.warn('STATIC-IDEAS markers not found in meal-ideas/index.html — static list skipped.');
  }
}
