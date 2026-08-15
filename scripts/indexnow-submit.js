#!/usr/bin/env node
// Submit URLs to IndexNow (Bing, Yandex, and — via Bing's index — AI answer
// engines like ChatGPT search). Instant "this page is new/changed" ping, far
// faster than waiting for a crawl.
//
// Self-contained: auto-discovers the IndexNow key file at the repo root
// (the <key>.txt Google/Bing verifies against) and reads the URL list from
// sitemap.xml. Re-run any time content changes.
//
//   node scripts/indexnow-submit.js            # submit every sitemap URL
//   node scripts/indexnow-submit.js <url> ...  # submit only the given URLs
//
// Note: the <key>.txt file must already be LIVE at https://momrise.app/<key>.txt
// (i.e. deployed via Pages) before submitting, or IndexNow rejects the batch.

const fs = require('fs');
const path = require('path');
const https = require('https');

const HOST = 'momrise.app';
const repoRoot = path.resolve(__dirname, '..');

function findKey() {
  const m = fs.readdirSync(repoRoot).find((f) => /^[a-f0-9]{16,64}\.txt$/i.test(f));
  if (!m) throw new Error('No IndexNow key file (<hex>.txt) found at repo root.');
  return { key: fs.readFileSync(path.join(repoRoot, m), 'utf8').trim(), file: m };
}

function urlsFromSitemap() {
  const xml = fs.readFileSync(path.join(repoRoot, 'sitemap.xml'), 'utf8');
  return [...xml.matchAll(/<loc>([^<]+)<\/loc>/g)].map((x) => x[1].trim());
}

function submit(key, keyLocation, urlList) {
  const body = JSON.stringify({ host: HOST, key, keyLocation, urlList });
  return new Promise((resolve, reject) => {
    const req = https.request('https://api.indexnow.org/indexnow', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=utf-8', 'Content-Length': Buffer.byteLength(body) },
    }, (res) => {
      let data = '';
      res.on('data', (c) => { data += c; });
      res.on('end', () => resolve({ status: res.statusCode, body: data }));
    });
    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

(async () => {
  const { key, file } = findKey();
  const keyLocation = `https://${HOST}/${file}`;
  const urls = process.argv.slice(2).length ? process.argv.slice(2) : urlsFromSitemap();
  if (urls.length === 0) { console.error('No URLs to submit.'); process.exit(1); }

  // IndexNow accepts up to 10k URLs/request; batch at 1k to be safe.
  for (let i = 0; i < urls.length; i += 1000) {
    const batch = urls.slice(i, i + 1000);
    const r = await submit(key, keyLocation, batch);
    console.log(`Submitted ${batch.length} URLs → HTTP ${r.status}${r.body ? ' ' + r.body.slice(0, 200) : ''}`);
    // 200 = accepted, 202 = accepted (pending verification). 4xx = problem.
    if (r.status >= 400) { console.error('IndexNow rejected the batch.'); process.exit(1); }
  }
  console.log(`Done. Key file: ${keyLocation}`);
})().catch((e) => { console.error(e); process.exit(1); });
