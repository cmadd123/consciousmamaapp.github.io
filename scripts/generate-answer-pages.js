// Answer Engine — page generator.
//
// Reads data/answers.json and emits answer-first Q&A pages at
// answers/{slug}/index.html plus a catalog at answers/index.html. Same
// structure/style as the comparison pages (compare/style.css): a 40–60 word
// direct answer AI answer engines can quote, then specifics, a practical
// "what to do" section, FAQ, sources, and a soft funnel to the app.
//
// Data model (per item):
//   slug, question (H1 + <title>), category, answer (40–60 words),
//   sections: [{ heading, blocks: [
//       { p: "text" } | { ul: ["…"] } | { ol: ["…"] } |
//       { table: { caption?, head: ["…"], rows: [["…"]] } } ] }],
//   cta { lead, body(html) }, faqs [{ q, a }], related [{ url, title }],
//   disclaimer, sources [{ title, publisher, url }], published, updated,
//   reviewer? { name, credentials }   <- OPTIONAL; never invent one.
// Any text may cite a source inline with a [n] marker (1-based).
//
// Run from the repo root:
//   node scripts/generate-answer-pages.js            # generate
//   node scripts/generate-answer-pages.js --dry-run  # log only

const fs = require('fs');
const path = require('path');
const {
  APP_STORE, PLAY_STORE, FOOTER,
  escapeHtml, escapeJson, truncate, stripRefs, withRefs,
  bylineHtml, sourcesHtml, articleLd, faqLd, relatedHtml, ogTags,
} = require('./lib/aeo-shared');

const repoRoot = path.resolve(__dirname, '..');
const dataPath = path.join(repoRoot, 'data', 'answers.json');
const outRoot = path.join(repoRoot, 'answers');
const dryRun = process.argv.includes('--dry-run');

function wordCount(s) {
  return stripRefs(String(s || '')).replace(/<[^>]+>/g, ' ').split(/\s+/).filter(Boolean).length;
}
function itemWords(a) {
  let n = wordCount(a.answer);
  for (const s of a.sections || []) {
    n += wordCount(s.heading);
    for (const b of s.blocks || []) {
      if (b.p) n += wordCount(b.p);
      for (const li of b.ul || b.ol || []) n += wordCount(li);
      if (b.table) for (const row of [b.table.head || [], ...(b.table.rows || [])]) for (const cell of row) n += wordCount(cell);
    }
  }
  for (const f of a.faqs || []) n += wordCount(f.q) + wordCount(f.a);
  return n;
}

function blockHtml(b, r) {
  if (b.p) return `\n      <p>${r(b.p)}</p>`;
  if (b.ul) return `\n      <ul>${b.ul.map((li) => `\n        <li>${r(li)}</li>`).join('')}\n      </ul>`;
  if (b.ol) return `\n      <ol>${b.ol.map((li) => `\n        <li>${r(li)}</li>`).join('')}\n      </ol>`;
  if (b.table) {
    const t = b.table;
    const head = (t.head || []).map((h) => `<th scope="col">${escapeHtml(h)}</th>`).join('');
    const rows = (t.rows || []).map((row) => `
            <tr>${row.map((cell, i) => (i === 0 ? `<th scope="row">${r(cell)}</th>` : `<td>${r(cell)}</td>`)).join('')}</tr>`).join('');
    return `
      <div class="table-wrap">
        <table class="cmp-table">${t.caption ? `\n          <caption>${escapeHtml(t.caption)}</caption>` : ''}
          <thead><tr>${head}</tr></thead>
          <tbody>${rows}
          </tbody>
        </table>
      </div>`;
  }
  return '';
}

function buildPage(a) {
  const url = `https://momrise.app/answers/${a.slug}/`;
  const plainDesc = truncate(stripRefs(a.answer), 200);
  const src = a.sources || [];
  const r = (s) => withRefs(s, src, a.slug);

  const article = JSON.stringify(articleLd({ headline: a.question, description: plainDesc, url, item: a }), null, 2);
  const faq = JSON.stringify(faqLd(a.faqs), null, 2);

  const sections = (a.sections || []).map((s) => `
    <section>
      <h2>${escapeHtml(s.heading)}</h2>${(s.blocks || []).map((b) => blockHtml(b, r)).join('')}
    </section>`).join('');

  const faqs = (a.faqs || []).map((f) => `
      <div class="faq-item">
        <h3>${escapeHtml(f.q)}</h3>
        <p>${r(f.a)}</p>
      </div>`).join('');

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(a.question)} — MomRise</title>
  <meta name="description" content="${escapeHtml(plainDesc)}">
  <link rel="canonical" href="${url}">

  ${ogTags({ url, title: a.question, description: plainDesc })}

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

  <main class="cmp ans">
    <p class="eyebrow">${escapeHtml(a.category || 'Parenting answers')}</p>
    <h1>${escapeHtml(a.question)}</h1>
    ${bylineHtml(a)}

    <!-- Answer-first: the block AI answer engines quote -->
    <section class="answer" aria-label="Short answer">
      <h2>Short answer</h2>
      <p>${r(a.answer)}</p>
    </section>
${sections}

    <div class="cta">
      <p class="cta-lead">${escapeHtml((a.cta && a.cta.lead) || 'Take the planning off your plate')}</p>
      <p>${(a.cta && a.cta.body) || 'MomRise builds a weekly family meal plan and grocery list around your kids’ ages and what they’ll actually eat.'}</p>
      <div class="app-buttons">
        <a class="store-btn" href="${APP_STORE}">App Store</a>
        <a class="store-btn" href="${PLAY_STORE}">Google Play</a>
      </div>
      <p class="cta-sub">Free 7-day trial · No credit card · Or try the free <a href="/meal-ideas/">meal-idea generator</a></p>
    </div>

    <section class="faq">
      <h2>Frequently asked questions</h2>${faqs}
    </section>

    ${relatedHtml(a.related, 'Related')}
    ${a.disclaimer ? `<p class="disclaimer">${escapeHtml(a.disclaimer)}</p>` : ''}
    ${sourcesHtml(src)}
  </main>

  ${FOOTER}
</body>
</html>
`;
}

function buildCatalog(items) {
  const url = 'https://momrise.app/answers/';
  const desc = 'Straight answers to the feeding questions parents ask most — portions, picky eating, allergens, choking hazards, iron, and milk — with sources from pediatric and public-health guidance.';
  const cards = items.map((a) => `
      <li><a href="/answers/${a.slug}/">
        <span class="c-cat">${escapeHtml(a.category || '')}</span>
        <span class="c-title">${escapeHtml(a.question)}</span>
      </a></li>`).join('');
  return `<!DOCTYPE html>
<html lang="en"><head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Parenting Answers: Feeding Babies &amp; Toddlers — MomRise</title>
  <meta name="description" content="${escapeHtml(desc)}">
  <link rel="canonical" href="${url}">
  ${ogTags({ url, title: 'Parenting Answers: Feeding Babies & Toddlers', description: desc, type: 'website' })}
  <link rel="stylesheet" href="/compare/style.css">
</head><body>
  <header class="page-header"><a href="/" class="brand"><span class="brand-mark">MomRise</span></a></header>
  <main class="catalog">
    <h1>Parenting answers</h1>
    <p class="catalog-sub">Short, sourced answers to everyday feeding questions. Weighing two options? See our <a href="/compare/">side-by-side comparisons</a>.</p>
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
console.log(`${dryRun ? 'DRY RUN — ' : ''}Generating ${items.length} answer page(s)…`);

let wrote = 0;
for (const a of items) {
  if (!a.slug || !a.question || !a.answer) {
    console.log(`  · Skip (missing slug/question/answer): ${a.slug || '(no slug)'}`);
    continue;
  }
  const aw = wordCount(a.answer);
  const tw = itemWords(a);
  const warn = (aw < 40 || aw > 60 ? ` ! short answer is ${aw} words (target 40–60)` : '')
    + (tw < 700 || tw > 1100 ? ` ! page is ${tw} words (target 700–1100)` : '');
  const html = buildPage(a);
  if (dryRun) {
    console.log(`  ⇢ would write answers/${a.slug}/index.html (${tw} words)${warn}`);
  } else {
    const dir = path.join(outRoot, a.slug);
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(path.join(dir, 'index.html'), html, 'utf8');
    console.log(`  ✓ answers/${a.slug}/index.html (${tw} words)${warn}`);
  }
  wrote++;
}

if (!dryRun && wrote > 0) {
  fs.mkdirSync(outRoot, { recursive: true });
  fs.writeFileSync(path.join(outRoot, 'index.html'), buildCatalog(items), 'utf8');
  console.log(`  ✓ answers/index.html (catalog of ${wrote})`);
}
console.log(`\nDone. ${wrote} page(s).`);
