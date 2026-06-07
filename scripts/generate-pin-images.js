// Generates 1000x1500 Pinterest pin images for every curated recipe.
// Uses Puppeteer to render an HTML template per recipe — recipe photo
// as background, recipe name overlay, "Save in MomRise" sticker.
//
// Output: scripts/output/pins/{slug}.png — one per curated recipe.
// Gitignored (large + regeneratable).
//
// Usage:
//   NODE_PATH=./admin/node_modules node scripts/generate-pin-images.js
//   NODE_PATH=./admin/node_modules node scripts/generate-pin-images.js --recipe ID
//
// Tweaks: edit buildPinHtml() to change the design. Re-run to regenerate all 64.

const admin = require('firebase-admin');
const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const outDir = path.join(repoRoot, 'scripts', 'output', 'pins');
const saPath = path.join(repoRoot, 'admin', 'service-account.json');

const oneRecipeIdx = process.argv.indexOf('--recipe');
const oneRecipeId = oneRecipeIdx > -1 ? process.argv[oneRecipeIdx + 1] : null;

admin.initializeApp({ credential: admin.credential.cert(require(saPath)) });
const db = admin.firestore();

// ----- helpers (kebab + slug match the recipe-page generator) -----

function kebab(s) {
  return String(s || '')
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .slice(0, 60);
}

function slugFor(recipe, docId) {
  return `${kebab(recipe.recipe_name)}-${docId.slice(-6)}` || `recipe-${docId.slice(-6)}`;
}

function escapeHtml(s) {
  return String(s || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

// Truncates recipe name to ~2 lines worth at the target font size. The
// overlay font sizes shrinks via CSS clamp for very long names; this is
// just a defensive cap.
function nameForOverlay(name) {
  const n = String(name || '').replace(/\s+/g, ' ').trim();
  if (n.length > 75) return n.slice(0, 72) + '…';
  return n;
}

// ----- the pin HTML template -----
// Single-file <head>-styled HTML rendered by Puppeteer at 1000x1500.
// Design notes baked in:
//   - 2:3 vertical (Pinterest gold standard).
//   - Image fills BG with darken gradient to keep text readable.
//   - Recipe name in big white serif, top-third — eye-catch on mobile feed.
//   - "Save in MomRise" pill bottom-center — sets honest expectation that
//     the destination is the app, not a recipe blog.
//   - Pink brand accent matches the app gradient + creator dashboard.
//   - Optional cook-time chip top-right — provides recipe info even
//     without Rich Pin display.
function buildPinHtml(recipe) {
  const name = escapeHtml(nameForOverlay(recipe.recipe_name));
  const image = escapeHtml(recipe.image_url || '');
  const cookTime = Math.round(Number(recipe.cooking_time) || 0);
  const prepTime = Math.round(Number(recipe.prepare_time) || 0);
  const total = cookTime + prepTime;
  const timeChip = total > 0 ? `${total} min` : '';

  return `<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&family=Inter:wght@500;600;700&display=swap" rel="stylesheet">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    width: 1000px; height: 1500px; overflow: hidden;
    font-family: 'Inter', system-ui, sans-serif;
    position: relative;
  }
  .pin {
    width: 1000px; height: 1500px;
    position: relative;
    background: #2A2A2A;
  }
  .photo {
    /* Slight zoom + center crop trims ~10% off each edge, killing most
       corner watermarks recipe blogs stamp on their images. */
    position: absolute;
    top: -8%; left: -8%; right: -8%; bottom: -8%;
    background-image: url('${image}');
    background-size: cover;
    background-position: center;
  }
  .darken {
    position: absolute; inset: 0;
    background:
      /* Top + bottom gradient covers banner-style watermarks */
      linear-gradient(180deg,
        rgba(0,0,0,0.62) 0%,
        rgba(0,0,0,0.10) 30%,
        rgba(0,0,0,0.10) 60%,
        rgba(0,0,0,0.88) 100%),
      /* Corner vignette covers stamp-style watermarks */
      radial-gradient(ellipse at center, rgba(0,0,0,0) 55%, rgba(0,0,0,0.35) 100%);
  }

  /* Top-left brand mark */
  .brand {
    position: absolute;
    top: 56px;
    left: 56px;
    display: flex; align-items: center; gap: 12px;
    color: white;
  }
  .brand-dot {
    width: 14px; height: 14px;
    background: #E97A8C;
    border-radius: 50%;
    box-shadow: 0 0 0 4px rgba(233, 122, 140, 0.25);
  }
  .brand-word {
    font-family: 'Inter';
    font-weight: 700;
    font-size: 26px;
    letter-spacing: 0.04em;
    text-transform: uppercase;
  }

  /* Top-right time chip */
  .time-chip {
    position: absolute;
    top: 56px;
    right: 56px;
    background: white;
    color: #2A2A2A;
    font-family: 'Inter';
    font-weight: 700;
    font-size: 22px;
    padding: 12px 22px;
    border-radius: 999px;
    letter-spacing: 0.02em;
    box-shadow: 0 6px 24px rgba(0,0,0,0.18);
  }

  /* Recipe name overlay — top third, big serif */
  .title-wrap {
    position: absolute;
    left: 56px;
    right: 56px;
    top: 220px;
    text-align: left;
  }
  .title {
    font-family: 'Playfair Display';
    font-weight: 900;
    font-size: 92px;
    line-height: 1.05;
    color: white;
    letter-spacing: -0.01em;
    text-shadow: 0 6px 24px rgba(0,0,0,0.45);
    /* shrink for long names */
    font-size: clamp(56px, 92px, 92px);
  }
  /* Smaller for very long titles */
  .title.long  { font-size: 72px; line-height: 1.07; }
  .title.xlong { font-size: 56px; line-height: 1.10; }

  /* Bottom CTA pill */
  .cta {
    position: absolute;
    left: 0; right: 0;
    bottom: 100px;
    display: flex; flex-direction: column; align-items: center; gap: 16px;
  }
  .cta-label {
    color: white;
    font-family: 'Inter';
    font-weight: 600;
    font-size: 22px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    opacity: 0.9;
  }
  .cta-pill {
    background: #E97A8C;
    color: white;
    font-family: 'Inter';
    font-weight: 700;
    font-size: 36px;
    padding: 20px 56px;
    border-radius: 999px;
    box-shadow: 0 14px 40px rgba(233, 122, 140, 0.45);
    letter-spacing: 0.01em;
  }
  .cta-foot {
    color: white;
    font-family: 'Inter';
    font-weight: 500;
    font-size: 22px;
    opacity: 0.85;
    margin-top: 8px;
    letter-spacing: 0.01em;
  }
</style>
</head>
<body>
  <div class="pin">
    <div class="photo"></div>
    <div class="darken"></div>

    <div class="brand">
      <div class="brand-dot"></div>
      <div class="brand-word">MomRise</div>
    </div>

    ${timeChip ? `<div class="time-chip">${timeChip}</div>` : ''}

    <div class="title-wrap">
      <h1 class="title ${name.length > 55 ? 'xlong' : (name.length > 35 ? 'long' : '')}">${name}</h1>
    </div>

    <div class="cta">
      <div class="cta-label">Save in</div>
      <div class="cta-pill">MomRise</div>
      <div class="cta-foot">Free meal-plan app · 7-day trial</div>
    </div>
  </div>
</body>
</html>`;
}

// ----- main -----

(async () => {
  let snap;
  if (oneRecipeId) {
    const doc = await db.collection('meal').doc(oneRecipeId).get();
    if (!doc.exists) {
      console.error(`No recipe found with id ${oneRecipeId}`);
      process.exit(1);
    }
    snap = { docs: [doc], size: 1 };
  } else {
    snap = await db.collection('meal').where('is_curated', '==', true).get();
  }

  console.log(`Rendering ${snap.size} pin image(s)…`);
  fs.mkdirSync(outDir, { recursive: true });

  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 1000, height: 1500, deviceScaleFactor: 1 });

  let wrote = 0;
  let skipped = 0;

  for (const doc of snap.docs) {
    const recipe = doc.data();
    if (!recipe.recipe_name || !recipe.image_url) {
      skipped++;
      console.log(`  · Skip ${doc.id} (${recipe.recipe_name || 'no name'}): missing name or image`);
      continue;
    }

    const slug = slugFor(recipe, doc.id);
    const html = buildPinHtml(recipe);

    try {
      await page.setContent(html, { waitUntil: 'networkidle0', timeout: 20000 });
      // Tiny extra wait to ensure fonts have rendered.
      await new Promise((r) => setTimeout(r, 250));
      const outPath = path.join(outDir, `${slug}.png`);
      await page.screenshot({
        path: outPath,
        type: 'png',
        clip: { x: 0, y: 0, width: 1000, height: 1500 },
      });
      console.log(`  ✓ ${slug}.png`);
      wrote++;
    } catch (e) {
      console.warn(`  ! ${slug}: ${e.message}`);
      skipped++;
    }
  }

  await browser.close();
  console.log(`\nDone. Wrote ${wrote}, skipped ${skipped}.`);
  console.log(`Output: ${outDir}`);
  process.exit(0);
})().catch((e) => { console.error(e); process.exit(1); });
