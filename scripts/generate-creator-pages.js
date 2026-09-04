// Creator-monetization content cluster generator.
//
// Reads data/creator-guides.json and emits AEO-structured guide pages at
// for-creators/{slug}/ plus a hub at for-creators/. These target family/recipe
// creators (IG + TikTok) searching how to monetize, and funnel to /apply/ —
// the inbound half of creator recruitment. Same engine shape as the
// comparison generator: answer-first, Article + FAQPage schema, no secrets.
//
//   node scripts/generate-creator-pages.js [--dry-run]

const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const dataPath = path.join(repoRoot, 'data', 'creator-guides.json');
const outRoot = path.join(repoRoot, 'for-creators');
const dryRun = process.argv.includes('--dry-run');

function escapeHtml(s) {
  return String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;').replace(/'/g, '&#039;');
}
function escapeJson(s) { return String(s == null ? '' : s).replace(/<\/script/gi, '<\\/script'); }
function truncate(s, n) { s = String(s || '').trim(); return s.length > n ? s.slice(0, n - 1).trimEnd() + '…' : s; }

function buildSchema(g) {
  const url = `https://momrise.app/for-creators/${g.slug}/`;
  const article = {
    '@context': 'https://schema.org', '@type': 'Article',
    headline: g.headline, description: truncate(g.answer, 200),
    author: { '@type': 'Organization', name: 'MomRise' },
    publisher: { '@type': 'Organization', name: 'MomRise' },
    dateModified: g.updated, mainEntityOfPage: url, url,
  };
  const faq = {
    '@context': 'https://schema.org', '@type': 'FAQPage',
    mainEntity: (g.faqs || []).map((f) => ({ '@type': 'Question', name: f.q, acceptedAnswer: { '@type': 'Answer', text: f.a } })),
  };
  return { article: JSON.stringify(article, null, 2), faq: JSON.stringify(faq, null, 2) };
}

// Pick up to `n` related guides — prefer same category, then fill with others.
function relatedGuides(g, all, n = 3) {
  const others = all.filter((x) => x.slug && x.slug !== g.slug);
  const sameCat = others.filter((x) => x.category === g.category);
  const rest = others.filter((x) => x.category !== g.category);
  return [...sameCat, ...rest].slice(0, n);
}

function buildPage(g, all = []) {
  const url = `https://momrise.app/for-creators/${g.slug}/`;
  const desc = escapeHtml(truncate(g.answer, 200));
  const { article, faq } = buildSchema(g);
  const sections = (g.sections || []).map((s) => `
    <section><h2>${escapeHtml(s.h)}</h2>${s.body}</section>`).join('');
  const faqs = (g.faqs || []).map((f) => `
      <div class="faq-item"><h3>${escapeHtml(f.q)}</h3><p>${escapeHtml(f.a)}</p></div>`).join('');
  const related = relatedGuides(g, all);
  const relatedHtml = related.length ? `
    <section class="related" aria-label="Related guides">
      <h2>Keep reading</h2>
      <ul class="c-grid">${related.map((r) => `
        <li><a href="/for-creators/${r.slug}/">
          <span class="c-cat">${escapeHtml(r.category || '')}</span>
          <span class="c-title">${escapeHtml(r.headline)}</span>
        </a></li>`).join('')}
      </ul>
    </section>` : '';
  const cta = g.cta || {};

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(g.headline)} — MomRise for Creators</title>
  <meta name="description" content="${desc}">
  <link rel="canonical" href="${url}">
  <meta property="og:type" content="article">
  <meta property="og:site_name" content="MomRise">
  <meta property="og:url" content="${url}">
  <meta property="og:title" content="${escapeHtml(g.headline)}">
  <meta property="og:description" content="${desc}">
  <script type="application/ld+json">
${escapeJson(article)}
  </script>
  <script type="application/ld+json">
${escapeJson(faq)}
  </script>
  <link rel="stylesheet" href="/for-creators/style.css">
</head>
<body>
  <header class="page-header"><a href="/" class="brand"><span class="brand-mark">MomRise</span></a>
    <a class="nav-cta" href="/apply/">Become a creator →</a>
  </header>

  <main class="guide">
    <p class="eyebrow">${escapeHtml(g.category || 'For creators')}</p>
    <h1>${escapeHtml(g.headline)}</h1>
    <p class="subhead">${escapeHtml(g.subhead || '')}</p>

    <section class="answer" aria-label="Quick answer">
      <h2>Short answer</h2>
      <p>${escapeHtml(g.answer)}</p>
    </section>

    ${sections}

    <div class="cta">
      <p class="cta-lead">${escapeHtml(cta.lead || 'Turn your audience into income')}</p>
      <p>${cta.body || 'MomRise pays you a percentage of every subscription from your audience — for as long as they stay — and turns your recipes into AI-discoverable pages that keep bringing in traffic. Free to join.'}</p>
      <a class="store-btn" href="/apply/">Apply to the MomRise creator program →</a>
    </div>

    <section class="faq">
      <h2>Frequently asked questions</h2>${faqs}
    </section>
    ${relatedHtml}
  </main>

  <footer class="page-footer">
    <a href="/">MomRise</a> · <a href="/for-creators/">For creators</a> · <a href="/apply/">Apply</a> · <a href="/privacy.html">Privacy</a>
  </footer>
</body>
</html>
`;
}

function buildHub(items) {
  const cards = items.map((g) => `
      <li><a href="/for-creators/${g.slug}/">
        <span class="c-cat">${escapeHtml(g.category || '')}</span>
        <span class="c-title">${escapeHtml(g.headline)}</span>
        <span class="c-sub">${escapeHtml(truncate(g.subhead || g.answer, 110))}</span>
      </a></li>`).join('');
  return `<!DOCTYPE html>
<html lang="en"><head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Creator Monetization Guides — MomRise for Creators</title>
  <meta name="description" content="How family and recipe creators on Instagram and TikTok grow and monetize their audience — plus how to get found by AI.">
  <link rel="canonical" href="https://momrise.app/for-creators/">
  <link rel="stylesheet" href="/for-creators/style.css">
</head><body>
  <header class="page-header"><a href="/" class="brand"><span class="brand-mark">MomRise</span></a>
    <a class="nav-cta" href="/apply/">Become a creator →</a>
  </header>
  <main class="hub">
    <h1>For food &amp; family creators</h1>
    <p class="hub-sub">How to grow and actually monetize your audience on Instagram and TikTok — and get your recipes found by AI.</p>
    <ul class="c-grid">${cards}
    </ul>
    <div class="cta">
      <p class="cta-lead">Earn from the audience you already have</p>
      <p>Join the MomRise creator program — a percentage of every subscription from your community, plus AI-discoverable recipe pages. Free to join.</p>
      <a class="store-btn" href="/apply/">Apply now →</a>
    </div>
  </main>
  <footer class="page-footer"><a href="/">MomRise</a> · <a href="/apply/">Apply</a></footer>
</body></html>
`;
}

// ---------- main ----------
const items = JSON.parse(fs.readFileSync(dataPath, 'utf8'));
console.log(`${dryRun ? 'DRY RUN — ' : ''}Generating ${items.length} creator guide(s)…`);
let wrote = 0;
for (const g of items) {
  if (!g.slug || !g.headline) { console.log(`  · skip (missing slug/headline)`); continue; }
  const html = buildPage(g, items);
  if (dryRun) { console.log(`  ⇢ for-creators/${g.slug}/ (${html.length}b)`); }
  else {
    fs.mkdirSync(path.join(outRoot, g.slug), { recursive: true });
    fs.writeFileSync(path.join(outRoot, g.slug, 'index.html'), html, 'utf8');
    console.log(`  ✓ for-creators/${g.slug}/index.html`);
  }
  wrote++;
}
if (!dryRun && wrote > 0) {
  fs.mkdirSync(outRoot, { recursive: true });
  fs.writeFileSync(path.join(outRoot, 'index.html'), buildHub(items), 'utf8');
  console.log(`  ✓ for-creators/index.html (hub of ${wrote})`);
}
console.log(`\nDone. ${wrote} page(s).`);
