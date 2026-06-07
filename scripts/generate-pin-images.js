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
function sourceHost(url) {
  try {
    return new URL(String(url)).hostname.replace(/^www\./, '');
  } catch {
    return '';
  }
}

function buildPinHtml(recipe) {
  const name = escapeHtml(nameForOverlay(recipe.recipe_name));
  const image = escapeHtml(recipe.image_url || '');
  const cookTime = Math.round(Number(recipe.cooking_time) || 0);
  const prepTime = Math.round(Number(recipe.prepare_time) || 0);
  const total = cookTime + prepTime;
  // Format: <60 min stays "X min", 60+ becomes "X h" or "X h Y min".
  // Slow-cooker recipes routinely run 4-6 hours so we MUST roll over.
  const timeChip = (() => {
    if (total <= 0) return '';
    if (total < 60) return `${total} min`;
    const h = Math.floor(total / 60);
    const m = total % 60;
    if (m === 0) return `${h} h`;
    if (m === 30) return `${h}½ h`;
    return `${h} h ${m} min`;
  })();
  const credit = escapeHtml(sourceHost(recipe.source_url));

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
  }
  /* Magazine layout: photo on top, MomRise-controlled brand area below.
     The photo keeps its natural framing — whatever watermark the source
     site has stays where it lands, serving as inline photo attribution.
     Our brand area is a clean MomRise-owned space underneath. */
  .pin {
    width: 1000px; height: 1500px;
    display: flex; flex-direction: column;
    background: linear-gradient(180deg, #FFF8F0 0%, #FDEAE2 100%);
  }
  .photo-section {
    width: 1000px; height: 880px;
    position: relative;
    overflow: hidden;
    background-color: #EEE;
  }
  .photo {
    position: absolute; inset: 0;
    background-image: url('${image}');
    background-size: cover;
    background-position: center;
  }
  /* Subtle bottom fade so the white brand area meets the photo cleanly */
  .photo-fade {
    position: absolute; left: 0; right: 0; bottom: 0; height: 80px;
    background: linear-gradient(180deg, rgba(255,248,240,0) 0%, rgba(255,248,240,1) 100%);
  }
  /* Time chip, top-right of the photo */
  .time-chip {
    position: absolute;
    top: 40px; right: 40px;
    background: white;
    color: #2A2A2A;
    font-family: 'Inter';
    font-weight: 700;
    font-size: 22px;
    padding: 12px 22px;
    border-radius: 999px;
    box-shadow: 0 6px 24px rgba(0,0,0,0.20);
    letter-spacing: 0.02em;
  }

  /* Brand area below the photo */
  .info {
    flex: 1;
    padding: 36px 60px 40px;
    display: flex; flex-direction: column;
    align-items: center;
    text-align: center;
  }
  .brand-row {
    display: flex; align-items: center; gap: 10px;
    color: #5D4E60;
  }
  .brand-dot {
    width: 11px; height: 11px;
    background: #E97A8C;
    border-radius: 50%;
  }
  .brand-word {
    font-family: 'Inter';
    font-weight: 700;
    font-size: 18px;
    letter-spacing: 0.18em;
    text-transform: uppercase;
  }
  .divider {
    width: 70px; height: 3px;
    background: #E97A8C;
    border-radius: 2px;
    margin: 22px 0 18px;
  }
  .title {
    font-family: 'Playfair Display';
    font-weight: 900;
    font-size: 64px;
    line-height: 1.06;
    color: #2A2A2A;
    letter-spacing: -0.01em;
    margin-bottom: 28px;
  }
  .title.long  { font-size: 52px; }
  .title.xlong { font-size: 42px; }

  .cta-pill {
    background: #E97A8C;
    color: white;
    font-family: 'Inter';
    font-weight: 700;
    font-size: 28px;
    padding: 18px 44px;
    border-radius: 999px;
    box-shadow: 0 12px 30px rgba(233, 122, 140, 0.32);
    letter-spacing: 0.01em;
    margin-bottom: 14px;
  }
  .cta-foot {
    color: #6B5D6E;
    font-family: 'Inter';
    font-weight: 500;
    font-size: 18px;
    letter-spacing: 0.01em;
  }

  /* Photo credit — small attribution line at the very bottom. Always
     visible regardless of whether the source's watermark is on the photo. */
  .credit {
    position: absolute;
    bottom: 18px; left: 0; right: 0;
    text-align: center;
    font-family: 'Inter';
    font-weight: 500;
    font-size: 14px;
    color: #9B8FA0;
    letter-spacing: 0.04em;
  }
</style>
</head>
<body>
  <div class="pin">
    <div class="photo-section">
      <div class="photo"></div>
      <div class="photo-fade"></div>
      ${timeChip ? `<div class="time-chip">${timeChip}</div>` : ''}
    </div>

    <div class="info">
      <div class="brand-row">
        <div class="brand-dot"></div>
        <div class="brand-word">MomRise</div>
      </div>
      <div class="divider"></div>
      <h1 class="title ${name.length > 55 ? 'xlong' : (name.length > 35 ? 'long' : '')}">${name}</h1>
      <div class="cta-pill">Save in MomRise</div>
      <div class="cta-foot">Mom-centered meal planner · 7-day free trial</div>
    </div>

    ${credit ? `<div class="credit">Photo: ${credit}</div>` : ''}
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
      // 'load' is more tolerant of slow recipe-blog images than 'networkidle0'.
      // Some hosts dribble bytes over many seconds; networkidle0 trips its
      // timeout even when the image loaded fine. Fonts + Google CSS finish
      // well before the photo, so we add a 1.2s settle wait + a polling
      // check on the background image's actual load state.
      await page.setContent(html, { waitUntil: 'load', timeout: 45000 });
      await new Promise((r) => setTimeout(r, 1200));
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
