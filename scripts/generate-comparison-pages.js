// Comparison-Authority Engine — page generator.
//
// Reads the facts-only "category graph" (data/comparisons.json) and emits
// AEO-structured static pages at compare/{slug}/index.html plus a catalog
// at compare/index.html. Facts only — no protected prose — and answer-first
// so AI answer engines can quote us. Funnels to the MomRise app.
//
// Trust layer (see scripts/lib/aeo-shared.js): each comparison carries
// `sources` [{title, publisher, url}] (cite inline with [n] markers in any
// copy field), `published` / `updated` dates, and an OPTIONAL `reviewer`
// {name, credentials} that renders only when set. `related` [{url, title}]
// cross-links to /answers/ pages.
//
// No Firebase / secrets needed. Run from the repo root:
//   node scripts/generate-comparison-pages.js            # generate
//   node scripts/generate-comparison-pages.js --dry-run  # log only

const fs = require('fs');
const path = require('path');
const {
  APP_STORE, PLAY_STORE, FOOTER,
  escapeHtml, escapeJson, truncate, stripRefs, withRefs,
  bylineHtml, sourcesHtml, articleLd, faqLd, relatedHtml, ogTags,
} = require('./lib/aeo-shared');

const repoRoot = path.resolve(__dirname, '..');
const dataPath = path.join(repoRoot, 'data', 'comparisons.json');
const outRoot = path.join(repoRoot, 'compare');
const dryRun = process.argv.includes('--dry-run');

function buildSchema(c) {
  const url = `https://momrise.app/compare/${c.slug}/`;
  const article = articleLd({
    headline: c.headline,
    description: truncate(stripRefs(c.answer), 200),
    url,
    item: c,
  });
  return {
    article: JSON.stringify(article, null, 2),
    faq: JSON.stringify(faqLd(c.faqs), null, 2),
  };
}

function buildPage(c) {
  const url = `https://momrise.app/compare/${c.slug}/`;
  const plainDesc = truncate(stripRefs(c.answer), 200);
  const desc = escapeHtml(plainDesc);
  const { article, faq } = buildSchema(c);
  const src = c.sources || [];
  const r = (s, ctx) => withRefs(s, src, `${c.slug}${ctx ? ' ' + ctx : ''}`);

  const tableRows = (c.table || []).map((row) => `
        <tr>
          <th scope="row">${escapeHtml(row.dim)}</th>
          <td>${r(row.a, 'table')}</td>
          <td>${r(row.b, 'table')}</td>
        </tr>`).join('');

  const bestFor = (c.bestFor || []).map((b) => `
        <li><span class="when">${r(b.when, 'bestFor')}</span><span class="pick">${escapeHtml(b.pick)}</span></li>`).join('');

  const faqs = (c.faqs || []).map((f) => `
      <div class="faq-item">
        <h3>${escapeHtml(f.q)}</h3>
        <p>${r(f.a, 'faq')}</p>
      </div>`).join('');

  const related = relatedHtml(c.related, 'Related parenting answers');

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(c.headline)} — MomRise</title>
  <meta name="description" content="${desc}">
  <link rel="canonical" href="${url}">

  ${ogTags({ url, title: c.headline, description: plainDesc })}

  <script type="application/ld+json">
${escapeJson(article)}
  </script>
  <script type="application/ld+json">
${escapeJson(faq)}
  </script>

  <link rel="stylesheet" href="/compare/style.css">
</head>
<body>
  <header class="page-header">
    <a href="/" class="brand"><span class="brand-mark">MomRise</span></a>
  </header>

  <main class="cmp">
    <p class="eyebrow">${escapeHtml(c.category || 'Comparison')}</p>
    <h1>${escapeHtml(c.headline)}</h1>
    <p class="subhead">${escapeHtml(c.subhead || '')}</p>
    ${bylineHtml(c)}

    <!-- Answer-first: the block AI answer engines quote -->
    <section class="answer" aria-label="Quick answer">
      <h2>Quick answer</h2>
      <p>${r(c.answer, 'answer')}</p>
    </section>

    <section class="versus">
      <div class="opt"><h2>${escapeHtml(c.a.name)}</h2><p>${r(c.a.blurb, 'a')}</p></div>
      <div class="opt"><h2>${escapeHtml(c.b.name)}</h2><p>${r(c.b.blurb, 'b')}</p></div>
    </section>

    <section class="table-wrap">
      <h2>Side-by-side comparison</h2>
      <table class="cmp-table">
        <thead>
          <tr><th scope="col"></th><th scope="col">${escapeHtml(c.a.name)}</th><th scope="col">${escapeHtml(c.b.name)}</th></tr>
        </thead>
        <tbody>${tableRows}
        </tbody>
      </table>
    </section>

    <section class="best-for">
      <h2>Which should you choose?</h2>
      <ul>${bestFor}
      </ul>
    </section>

    <!-- App funnel (per-comparison, falls back to a generic MomRise pitch) -->
    <div class="cta">
      <p class="cta-lead">${escapeHtml((c.cta && c.cta.lead) || 'One app for the whole parenting journey')}</p>
      <p>${(c.cta && c.cta.body) || 'MomRise plans meals, tracks milestones, and turns everyday parenting challenges into simple, age-appropriate daily steps.'}</p>
      <div class="app-buttons">
        <a class="store-btn" href="${APP_STORE}">App Store</a>
        <a class="store-btn" href="${PLAY_STORE}">Google Play</a>
      </div>
      <p class="cta-sub">Free 7-day trial · No credit card</p>
    </div>

    <section class="faq">
      <h2>Frequently asked questions</h2>${faqs}
    </section>

    ${related}
    ${c.disclaimer ? `<p class="disclaimer">${escapeHtml(c.disclaimer)}</p>` : ''}
    ${sourcesHtml(src)}
  </main>

  ${FOOTER}
</body>
</html>
`;
}

function buildCatalog(items) {
  const url = 'https://momrise.app/compare/';
  const title = 'Parenting Comparisons — MomRise';
  const desc = 'Neutral, side-by-side parenting comparisons — feeding, sleep, gear, and play choices explained, with sources from pediatric and public-health guidance.';
  const cards = items.map((c) => `
      <li><a href="/compare/${c.slug}/">
        <span class="c-cat">${escapeHtml(c.category || '')}</span>
        <span class="c-title">${escapeHtml(c.headline)}</span>
      </a></li>`).join('');
  return `<!DOCTYPE html>
<html lang="en"><head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${title}</title>
  <meta name="description" content="${escapeHtml(desc)}">
  <link rel="canonical" href="${url}">
  ${ogTags({ url, title: 'Parenting Comparisons', description: desc, type: 'website' })}
  <link rel="stylesheet" href="/compare/style.css">
</head><body>
  <header class="page-header"><a href="/" class="brand"><span class="brand-mark">MomRise</span></a></header>
  <main class="catalog">
    <h1>Parenting comparisons</h1>
    <p class="catalog-sub">Neutral, side-by-side breakdowns to help you decide. Looking for a quick answer instead? See <a href="/answers/">parenting answers</a>.</p>
    <ul class="c-grid">${cards}
    </ul>
  </main>
  ${FOOTER}
</body></html>
`;
}

// ---------- main ----------
const raw = JSON.parse(fs.readFileSync(dataPath, 'utf8'));
const items = Array.isArray(raw) ? raw : [];
console.log(`${dryRun ? 'DRY RUN — ' : ''}Generating ${items.length} comparison page(s)…`);

let wrote = 0;
for (const c of items) {
  if (!c.slug || !c.headline || !c.a || !c.b) {
    console.log(`  · Skip (missing slug/headline/a/b): ${c.slug || '(no slug)'}`);
    continue;
  }
  const html = buildPage(c);
  if (dryRun) {
    console.log(`  ⇢ would write compare/${c.slug}/index.html (${html.length} bytes)`);
  } else {
    const dir = path.join(outRoot, c.slug);
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(path.join(dir, 'index.html'), html, 'utf8');
    console.log(`  ✓ compare/${c.slug}/index.html`);
  }
  wrote++;
}

if (!dryRun && wrote > 0) {
  fs.mkdirSync(outRoot, { recursive: true });
  fs.writeFileSync(path.join(outRoot, 'index.html'), buildCatalog(items), 'utf8');
  console.log(`  ✓ compare/index.html (catalog of ${wrote})`);
}
console.log(`\nDone. ${wrote} page(s).`);
