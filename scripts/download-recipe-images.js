// Downloads every curated recipe's hero image into scripts/output/recipe-photos/
// so you can flip through them in a file browser and spot which have visible
// watermarks. Filename includes recipe name + source domain so you know which
// recipes to fix or de-curate without cross-referencing Firestore.
//
// Usage: NODE_PATH=./admin/node_modules node scripts/download-recipe-images.js

const admin = require('firebase-admin');
const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const outDir = path.join(repoRoot, 'scripts', 'output', 'recipe-photos');
const saPath = path.join(repoRoot, 'admin', 'service-account.json');
admin.initializeApp({ credential: admin.credential.cert(require(saPath)) });
const db = admin.firestore();

const PARALLEL = 6;

function kebab(s) {
  return String(s || '').toLowerCase().replace(/[^\w\s-]/g, '').trim().replace(/\s+/g, '-').replace(/-+/g, '-').slice(0, 50);
}
function sourceHost(url) {
  try { return new URL(String(url)).hostname.replace(/^www\./, ''); }
  catch { return 'unknown'; }
}
function extFromContentType(ct) {
  if (!ct) return '.jpg';
  if (ct.includes('webp')) return '.webp';
  if (ct.includes('png')) return '.png';
  if (ct.includes('gif')) return '.gif';
  return '.jpg';
}

async function downloadOne(url, depth = 0) {
  if (depth > 3) throw new Error('redirect-loop');
  return new Promise((resolve, reject) => {
    let u;
    try { u = new URL(url); } catch { return reject(new Error('invalid-url')); }
    const lib = u.protocol === 'http:' ? http : https;
    const req = lib.get({
      hostname: u.hostname,
      port: u.port || (u.protocol === 'http:' ? 80 : 443),
      path: u.pathname + u.search,
      headers: { 'User-Agent': 'Mozilla/5.0 MomRise-Audit/1.0' },
      timeout: 20000,
    }, async (res) => {
      if ([301, 302, 303, 307, 308].includes(res.statusCode) && res.headers.location) {
        const next = new URL(res.headers.location, url).toString();
        try { resolve(await downloadOne(next, depth + 1)); } catch (e) { reject(e); }
        return;
      }
      if (res.statusCode !== 200) return reject(new Error(`HTTP ${res.statusCode}`));
      const chunks = [];
      res.on('data', (c) => chunks.push(c));
      res.on('end', () => resolve({ buffer: Buffer.concat(chunks), contentType: res.headers['content-type'] || '' }));
    });
    req.on('error', reject);
    req.on('timeout', () => { req.destroy(); reject(new Error('timeout')); });
  });
}

(async () => {
  fs.mkdirSync(outDir, { recursive: true });
  const snap = await db.collection('meal').where('is_curated', '==', true).get();
  console.log(`Downloading ${snap.size} recipe images to ${outDir}\n`);

  const queue = snap.docs.map((doc) => ({ doc, recipe: doc.data() }));
  let done = 0;
  let failed = 0;

  await new Promise((resolve) => {
    let idx = 0;
    let inFlight = 0;
    function pump() {
      while (inFlight < PARALLEL && idx < queue.length) {
        const { doc, recipe } = queue[idx++];
        if (!recipe.image_url) {
          console.log(`  ! ${doc.id} (${recipe.recipe_name}): no image`);
          failed++;
          continue;
        }
        inFlight++;
        const host = sourceHost(recipe.source_url);
        const name = kebab(recipe.recipe_name);
        downloadOne(recipe.image_url).then(({ buffer, contentType }) => {
          const ext = extFromContentType(contentType);
          const fn = `${name}__${host}__${doc.id.slice(-6)}${ext}`;
          fs.writeFileSync(path.join(outDir, fn), buffer);
          done++;
          if (done % 5 === 0) process.stdout.write(`  …${done}/${queue.length}\n`);
        }).catch((e) => {
          console.log(`  ! ${name}__${host}: ${e.message}`);
          failed++;
        }).finally(() => {
          inFlight--;
          if (idx >= queue.length && inFlight === 0) resolve();
          else pump();
        });
      }
    }
    pump();
  });

  console.log(`\nDone. ${done} downloaded, ${failed} failed.`);
  console.log(`Open the folder in Windows Explorer or Finder — switch to large-icon view — flip through them, note the watermarked ones by source domain in the filename.`);
  process.exit(0);
})().catch((e) => { console.error(e); process.exit(1); });
