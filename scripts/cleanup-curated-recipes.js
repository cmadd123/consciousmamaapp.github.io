// Cleanup pass for curated recipes powering /r/ pages:
//   1) Try to upgrade WordPress thumbnail image URLs (`-225x225`, `-150x150`,
//      etc.) to their full-size variant. Verifies the larger URL returns
//      a real image before writing.
//   2) Un-curate recipes that are unfit for Pinterest publication:
//        - No image_url
//        - Image URL still broken after thumbnail repair attempt
//        - No ingredients OR no instructions
//      `is_curated == false` removes them from the meal-planner default
//      catalog AND prevents the recipe page generator from picking them up.
//      Recipe data itself is preserved.
//
// Dry-run by default. Use --commit to apply changes.

const admin = require('firebase-admin');
const https = require('https');
const http = require('http');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const saPath = path.join(repoRoot, 'admin', 'service-account.json');
admin.initializeApp({ credential: admin.credential.cert(require(saPath)) });
const db = admin.firestore();

const commit = process.argv.includes('--commit');

// ----- HEAD helpers (reused from audit) -----
function head(url) {
  return new Promise((resolve) => {
    let u;
    try { u = new URL(url); } catch { return resolve({ ok: false, error: 'invalid-url' }); }
    const lib = u.protocol === 'http:' ? http : https;
    const req = lib.request({
      method: 'HEAD',
      hostname: u.hostname,
      port: u.port || (u.protocol === 'http:' ? 80 : 443),
      path: u.pathname + u.search,
      headers: { 'User-Agent': 'MomRise-Cleanup/1.0' },
      timeout: 8000,
    }, (res) => {
      const status = res.statusCode;
      const ct = res.headers['content-type'] || '';
      const cl = Number(res.headers['content-length'] || 0);
      if ([301, 302, 303, 307, 308].includes(status) && res.headers.location) {
        return resolve({ ok: false, status, redirect: res.headers.location });
      }
      resolve({
        ok: status >= 200 && status < 400 && ct.startsWith('image/'),
        status, contentType: ct, sizeBytes: cl,
      });
    });
    req.on('error', (e) => resolve({ ok: false, error: e.message || 'network-error' }));
    req.on('timeout', () => { req.destroy(); resolve({ ok: false, error: 'timeout' }); });
    req.end();
  });
}
async function check(url, depth = 0) {
  if (depth > 3) return { ok: false, error: 'redirect-loop' };
  const r = await head(url);
  if (r.redirect) return check(new URL(r.redirect, url).toString(), depth + 1);
  return r;
}

// ----- Thumbnail-stripping logic -----
// WordPress thumbnails are typically `name-WIDTHxHEIGHT.ext`. Stripping the
// `-225x225` (or similar) usually yields the full-size image.
function thumbnailCandidates(url) {
  const candidates = [];
  // Pattern 1: -WxH right before the extension
  const m = url.match(/^(.*?)-\d+x\d+(\.[a-z0-9]+)(\?[^#]*)?(#.*)?$/i);
  if (m) {
    candidates.push(m[1] + m[2] + (m[3] || '') + (m[4] || ''));
  }
  // Pattern 2: `?fit=WxH` or `?resize=WxH` query params (strip them)
  if (/[?&](fit|resize|w|h)=/.test(url)) {
    const stripped = url.replace(/[?&](fit|resize|w|h)=[^&]*/g, '').replace(/[?&]ssl=1$/, '');
    if (stripped !== url) candidates.push(stripped);
  }
  return candidates;
}

async function tryUpgradeImage(url) {
  if (!url) return { upgraded: false, reason: 'no-url' };
  const candidates = thumbnailCandidates(url);
  for (const candidate of candidates) {
    const r = await check(candidate);
    if (r.ok && r.sizeBytes > 30 * 1024) {
      return { upgraded: true, newUrl: candidate, sizeBytes: r.sizeBytes };
    }
  }
  return { upgraded: false };
}

(async () => {
  const snap = await db.collection('meal').where('is_curated', '==', true).get();
  console.log(`Auditing ${snap.size} curated recipes…\n`);
  console.log(commit ? '⚠ COMMIT mode — Firestore will be updated\n' : 'DRY RUN — no writes (pass --commit to apply)\n');

  let upgradedCount = 0;
  let unCuratedCount = 0;
  const upgrades = [];
  const unCurations = [];

  for (const doc of snap.docs) {
    const r = doc.data();
    const hasIngredients = Array.isArray(r.ingredients) && r.ingredients.length > 0;
    const hasInstructions = Array.isArray(r.CookingInstructions) && r.CookingInstructions.length > 0;
    const oldUrl = r.image_url || '';

    // Step 1: upgrade thumbnail if applicable.
    let newUrl = oldUrl;
    let imageOk = false;
    if (oldUrl) {
      const initial = await check(oldUrl);
      if (initial.ok && initial.sizeBytes >= 30 * 1024) {
        imageOk = true;
      } else {
        // Try thumbnail upgrade.
        const upgrade = await tryUpgradeImage(oldUrl);
        if (upgrade.upgraded) {
          newUrl = upgrade.newUrl;
          imageOk = true;
          upgrades.push({ id: doc.id, name: r.recipe_name, old: oldUrl, new: newUrl, size: upgrade.sizeBytes });
          upgradedCount++;
          if (commit) {
            await doc.ref.update({ image_url: newUrl });
          }
        }
      }
    }

    // Step 2: un-curate if any fatal issue remains.
    const reasons = [];
    if (!newUrl) reasons.push('no-image');
    if (newUrl && !imageOk) reasons.push('broken-image');
    if (!hasIngredients) reasons.push('no-ingredients');
    if (!hasInstructions) reasons.push('no-instructions');

    if (reasons.length > 0) {
      unCurations.push({ id: doc.id, name: r.recipe_name, reasons });
      unCuratedCount++;
      if (commit) {
        await doc.ref.update({ is_curated: false });
      }
    }
  }

  // ----- Report -----
  if (upgrades.length > 0) {
    console.log(`\n=== Image upgrades (${upgrades.length}) ===\n`);
    for (const u of upgrades) {
      console.log(`  ${u.id} — ${u.name}`);
      console.log(`    old: ${u.old}`);
      console.log(`    new: ${u.new}  (${(u.size / 1024).toFixed(0)} KB)\n`);
    }
  } else {
    console.log('No thumbnail upgrades found.');
  }

  if (unCurations.length > 0) {
    console.log(`\n=== Un-curated (${unCurations.length}) ===\n`);
    for (const u of unCurations) {
      console.log(`  ${u.id} — ${u.name}  [${u.reasons.join(', ')}]`);
    }
  } else {
    console.log('No recipes need un-curating.');
  }

  console.log(`\n=== Summary ===`);
  console.log(`  Image URLs upgraded:  ${upgradedCount}`);
  console.log(`  Recipes un-curated:   ${unCuratedCount}`);
  console.log(`  Curated remaining:    ${snap.size - unCuratedCount}`);
  console.log(commit ? '\n✓ Firestore updated.' : '\n(dry-run — re-run with --commit to apply)');
  process.exit(0);
})().catch((e) => { console.error(e); process.exit(1); });
