// Comparison-Authority Engine — page generator.
//
// Reads the facts-only "category graph" (data/comparisons.json) and emits
// AEO-structured static pages at compare/{slug}/index.html plus a catalog
// at compare/index.html. Facts only — no protected prose — and answer-first
// so AI answer engines can quote us. Funnels to the MomRise app.
//
// No Firebase / secrets needed. Run from the repo root:
//   node scripts/generate-comparison-pages.js            # generate
//   node scripts/generate-comparison-pages.js --dry-run  # log only

const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const dataPath = path.join(repoRoot, 'data', 'comparisons.json');
const outRoot = path.join(repoRoot, 'compare');
const dryRun = process.argv.includes('--dry-run');

const APP_STORE = 'https://apps.apple.com/app/id6758357382';
const PLAY_STORE = 'https://play.google.com/store/apps/details?id=com.momrise.app';

function escapeHtml(s) {
  return String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;').replace(/'/g, '&#039;');
}
function escapeJson(s) {
  return String(s == null ? '' : s).replace(/<\/script/gi, '<\\/script');
}
function truncate(s, n) {
  s = String(s || '').trim();
  return s.length > n ? s.slice(0, n - 1).trimEnd() + '…' : s;
}

function buildSchema(c) {
  const url = `https://momrise.app/compare/${c.slug}/`;
  const article = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: c.headline,
    description: truncate(c.answer, 200),
    author: { '@type': 'Organization', name: 'MomRise' },
    publisher: { '@type': 'Organization', name: 'MomRise' },
    dateModified: c.updated,
    mainEntityOfPage: url,
    url,
  };
  const faq = {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: (c.faqs || []).map((f) => ({
      '@type': 'Question',
      name: f.q,
      acceptedAnswer: { '@type': 'Answer', text: f.a },
    })),
  };
  return { article: JSON.stringify(article, null, 2), faq: JSON.stringify(faq, null, 2) };
}

function buildPage(c) {
  const url = `https://momrise.app/compare/${c.slug}/`;
  const desc = escapeHtml(truncate(c.answer, 200));
  const { article, faq } = buildSchema(c);

  const tableRows = (c.table || []).map((r) => `
        <tr>
          <th scope="row">${escapeHtml(r.dim)}</th>
          <td>${escapeHtml(r.a)}</td>
          <td>${escapeHtml(r.b)}</td>
        </tr>`).join('');

  const bestFor = (c.bestFor || []).map((b) => `
        <li><span class="when">${escapeHtml(b.when)}</span><span class="pick">${escapeHtml(b.pick)}</span></li>`).join('');

  const faqs = (c.faqs || []).map((f) => `
      <div class="faq-item">
        <h3>${escapeHtml(f.q)}</h3>
        <p>${escapeHtml(f.a)}</p>
      </div>`).join('');

  const sources = (c.sources || []).map((s) => `<li>${escapeHtml(s)}</li>`).join('');

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(c.headline)} — MomRise</title>
  <meta name="description" content="${desc}">
  <link rel="canonical" href="${url}">

  <meta property="og:type" content="article">
  <meta property="og:site_name" content="MomRise">
  <meta property="og:url" content="${url}">
  <meta property="og:title" content="${escapeHtml(c.headline)}">
  <meta property="og:description" content="${desc}">

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

    <!-- Answer-first: the block AI answer engines quote -->
    <section class="answer" aria-label="Quick answer">
      <h2>Quick answer</h2>
      <p>${escapeHtml(c.answer)}</p>
    </section>

    <section class="versus">
      <div class="opt"><h2>${escapeHtml(c.a.name)}</h2><p>${escapeHtml(c.a.blurb)}</p></div>
      <div class="opt"><h2>${escapeHtml(c.b.name)}</h2><p>${escapeHtml(c.b.blurb)}</p></div>
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

    <!-- App funnel -->
    <div class="cta">
      <p class="cta-lead">Feeding a new eater?</p>
      <p>MomRise builds <strong>age-appropriate weekly meal plans</strong> and grocery lists as your baby grows — so you're not guessing what to serve next.</p>
      <div class="app-buttons">
        <a class="store-btn" href="${APP_STORE}">App Store</a>
        <a class="store-btn" href="${PLAY_STORE}">Google Play</a>
      </div>
      <p class="cta-sub">Free 7-day trial · No credit card</p>
    </div>

    <section class="faq">
      <h2>Frequently asked questions</h2>${faqs}
    </section>

    ${c.disclaimer ? `<p class="disclaimer">${escapeHtml(c.disclaimer)}</p>` : ''}
    ${sources ? `<section class="sources"><h2>Sources</h2><ul>${sources}</ul></section>` : ''}
  </main>

  <footer class="page-footer">
    <a href="/">MomRise</a> · <a href="/compare/">Compare</a> · <a href="/privacy.html">Privacy</a>
  </footer>
</body>
</html>
`;
}

function buildCatalog(items) {
  const cards = items.map((c) => `
      <li><a href="/compare/${c.slug}/">
        <span class="c-cat">${escapeHtml(c.category || '')}</span>
        <span class="c-title">${escapeHtml(c.headline)}</span>
      </a></li>`).join('');
  return `<!DOCTYPE html>
<html lang="en"><head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Parenting Comparisons — MomRise</title>
  <meta name="description" content="Neutral, side-by-side parenting comparisons — methods, approaches, and choices explained.">
  <link rel="canonical" href="https://momrise.app/compare/">
  <link rel="stylesheet" href="/compare/style.css">
</head><body>
  <header class="page-header"><a href="/" class="brand"><span class="brand-mark">MomRise</span></a></header>
  <main class="catalog">
    <h1>Parenting comparisons</h1>
    <p class="catalog-sub">Neutral, side-by-side breakdowns to help you decide.</p>
    <ul class="c-grid">${cards}
    </ul>
  </main>
  <footer class="page-footer"><a href="/">MomRise</a></footer>
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
