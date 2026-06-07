// Audits image quality on all curated recipes. HEAD-requests every
// image_url, flags anything that looks like a test/placeholder/broken.
// Read-only — no writes.
//
// Usage: NODE_PATH=./admin/node_modules node scripts/audit-recipe-images.js

const admin = require('firebase-admin');
const https = require('https');
const http = require('http');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const saPath = path.join(repoRoot, 'admin', 'service-account.json');
admin.initializeApp({ credential: admin.credential.cert(require(saPath)) });
const db = admin.firestore();

const PARALLEL = 8;

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
      headers: { 'User-Agent': 'MomRise-Audit/1.0' },
      timeout: 8000,
    }, (res) => {
      const status = res.statusCode;
      const ct = res.headers['content-type'] || '';
      const cl = Number(res.headers['content-length'] || 0);
      // Follow redirects manually (up to 3)
      if ([301, 302, 303, 307, 308].includes(status) && res.headers.location) {
        return resolve({ ok: false, status, redirect: res.headers.location });
      }
      resolve({
        ok: status >= 200 && status < 400 && ct.startsWith('image/'),
        status,
        contentType: ct,
        sizeBytes: cl,
      });
    });
    req.on('error', (e) => resolve({ ok: false, error: e.message || 'network-error' }));
    req.on('timeout', () => { req.destroy(); resolve({ ok: false, error: 'timeout' }); });
    req.end();
  });
}

async function followRedirects(url, depth = 0) {
  if (depth > 3) return { ok: false, error: 'redirect-loop' };
  const r = await head(url);
  if (r.redirect) {
    const next = new URL(r.redirect, url).toString();
    return followRedirects(next, depth + 1);
  }
  return r;
}

function looksTestName(name) {
  const n = String(name || '').trim().toLowerCase();
  if (n.length < 4) return true;
  if (/^(test|asdf|recipe|untitled|new|tmp|temp|delete|todo|placeholder)\b/.test(n)) return true;
  if (n.split(/\s+/).length === 1 && n.length < 8) return true;
  return false;
}

(async () => {
  const snap = await db.collection('meal').where('is_curated', '==', true).get();
  console.log(`Auditing ${snap.size} curated recipes…\n`);

  const rows = snap.docs.map((doc) => {
    const r = doc.data();
    return {
      id: doc.id,
      name: r.recipe_name || '(no name)',
      imageUrl: r.image_url || '',
      sourceUrl: r.source_url || '',
      hasIngredients: Array.isArray(r.ingredients) && r.ingredients.length > 0,
      hasInstructions: Array.isArray(r.CookingInstructions) && r.CookingInstructions.length > 0,
      flags: [],
    };
  });

  // Surface easy flags first (no fetch needed)
  for (const row of rows) {
    if (!row.imageUrl) row.flags.push('NO_IMAGE');
    if (looksTestName(row.name)) row.flags.push('TEST_NAME');
    if (!row.hasIngredients) row.flags.push('NO_INGREDIENTS');
    if (!row.hasInstructions) row.flags.push('NO_INSTRUCTIONS');
  }

  // Parallel HEAD requests for images
  const queue = rows.filter((r) => r.imageUrl);
  let inFlight = 0;
  let done = 0;

  await new Promise((resolve) => {
    let idx = 0;
    function pump() {
      while (inFlight < PARALLEL && idx < queue.length) {
        const row = queue[idx++];
        inFlight++;
        followRedirects(row.imageUrl).then((r) => {
          row.imageStatus = r.status || (r.ok ? 200 : 'err');
          row.imageContentType = r.contentType || r.error || '';
          row.imageSize = r.sizeBytes || 0;
          if (!r.ok) row.flags.push('IMAGE_BAD_FETCH');
          else if (r.sizeBytes > 0 && r.sizeBytes < 30 * 1024) row.flags.push('IMAGE_SMALL'); // < 30KB
          inFlight--;
          done++;
          if (done % 10 === 0) process.stdout.write(`  …${done}/${queue.length}\n`);
          if (idx >= queue.length && inFlight === 0) resolve();
          else pump();
        });
      }
    }
    pump();
  });

  console.log('\n=== Results ===\n');

  const noImage = rows.filter((r) => r.flags.includes('NO_IMAGE'));
  const badFetch = rows.filter((r) => r.flags.includes('IMAGE_BAD_FETCH'));
  const small = rows.filter((r) => r.flags.includes('IMAGE_SMALL'));
  const testName = rows.filter((r) => r.flags.includes('TEST_NAME'));
  const noIngredients = rows.filter((r) => r.flags.includes('NO_INGREDIENTS'));
  const noInstructions = rows.filter((r) => r.flags.includes('NO_INSTRUCTIONS'));

  function printSection(title, items) {
    if (items.length === 0) return;
    console.log(`\n## ${title} (${items.length})\n`);
    for (const r of items) {
      const extra = r.imageStatus ? `[${r.imageStatus}, ${(r.imageSize / 1024).toFixed(0)}KB, ${r.imageContentType}]` : '';
      console.log(`  ${r.id}`);
      console.log(`    name: ${r.name}`);
      if (r.imageUrl) console.log(`    image: ${r.imageUrl} ${extra}`);
      if (r.sourceUrl) console.log(`    source: ${r.sourceUrl}`);
      console.log('');
    }
  }

  printSection('Recipes with NO image', noImage);
  printSection('Recipes where image FETCH FAILED', badFetch);
  printSection('Recipes with SUSPICIOUSLY SMALL image (<30KB — likely placeholder)', small);
  printSection('Recipes with TEST-looking names', testName);
  printSection('Recipes missing ingredients', noIngredients);
  printSection('Recipes missing instructions', noInstructions);

  const allFlagged = rows.filter((r) => r.flags.length > 0);
  console.log(`\n=== Summary ===`);
  console.log(`  Total curated: ${rows.length}`);
  console.log(`  Clean: ${rows.length - allFlagged.length}`);
  console.log(`  Flagged: ${allFlagged.length}`);
  console.log(`    NO_IMAGE: ${noImage.length}`);
  console.log(`    IMAGE_BAD_FETCH: ${badFetch.length}`);
  console.log(`    IMAGE_SMALL: ${small.length}`);
  console.log(`    TEST_NAME: ${testName.length}`);
  console.log(`    NO_INGREDIENTS: ${noIngredients.length}`);
  console.log(`    NO_INSTRUCTIONS: ${noInstructions.length}`);

  process.exit(0);
})().catch((e) => { console.error(e); process.exit(1); });
