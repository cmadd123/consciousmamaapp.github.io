// Sets is_curated=false on a hardcoded list of recipes. Used to remove
// specific recipes from the Pinterest corpus and the meal-planner
// default catalog when their hero photo has a visible source-blog
// watermark we can't work around.
//
// Recipes don't get deleted — just un-curated. is_curated:false removes
// them from the recipe-page generator and the in-app catalog. They
// remain in Firestore in case we want them back.
//
// Usage:
//   NODE_PATH=./admin/node_modules node scripts/cull-recipes-by-name.js
//   NODE_PATH=./admin/node_modules node scripts/cull-recipes-by-name.js --commit

const admin = require('firebase-admin');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const saPath = path.join(repoRoot, 'admin', 'service-account.json');
admin.initializeApp({ credential: admin.credential.cert(require(saPath)) });
const db = admin.firestore();

const commit = process.argv.includes('--commit');

// Match against recipe_name (case-insensitive substring). Listed in the
// order the user identified them after auditing the photo folder for
// visible source-blog watermarks.
const TO_CULL = [
  'marry me chicken',
  'easy apple crumble',
  'one hour dinner rolls',
  'sausage hashbrown breakfast',
];

(async () => {
  const snap = await db.collection('meal').where('is_curated', '==', true).get();
  console.log(`Scanning ${snap.size} curated recipes…\n`);

  const matches = [];
  for (const doc of snap.docs) {
    const name = (doc.data().recipe_name || '').toLowerCase();
    for (const needle of TO_CULL) {
      if (name.includes(needle)) {
        matches.push({ doc, needle });
        break;
      }
    }
  }

  console.log(`Matched ${matches.length} of ${TO_CULL.length} expected:\n`);
  for (const m of matches) {
    console.log(`  ${m.doc.id} — "${m.doc.data().recipe_name}"`);
    console.log(`    matched on: "${m.needle}"`);
  }

  // Flag unmatched targets so the user knows if a typo missed one.
  const matchedNeedles = new Set(matches.map(m => m.needle));
  const unmatched = TO_CULL.filter(n => !matchedNeedles.has(n));
  if (unmatched.length > 0) {
    console.log(`\nUnmatched (check spelling):`);
    for (const n of unmatched) console.log(`  - "${n}"`);
  }

  if (!commit) {
    console.log(`\nDry-run only. Re-run with --commit to apply.`);
    process.exit(0);
  }

  console.log(`\nApplying is_curated=false…`);
  for (const m of matches) {
    await m.doc.ref.update({ is_curated: false });
    console.log(`  ✓ ${m.doc.id}`);
  }
  console.log(`\nDone. ${matches.length} recipes un-curated.`);
  console.log(`Next: regenerate /r/ pages (NODE_PATH=./admin/node_modules node scripts/generate-recipe-pages.js)`);
  process.exit(0);
})().catch((e) => { console.error(e); process.exit(1); });
