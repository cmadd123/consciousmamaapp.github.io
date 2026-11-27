// App-roundup pages ("best meal planning apps", "Mealime alternatives") for
// generate-comparison-pages.js. Entries in data/comparisons.json with
// `type: "app-roundup"` are rendered here from the app category graph in
// data/meal-planning-apps.json.
//
// Self-participant guardrail (COMPARISON_AUTHORITY_ENGINE_SPEC.md): MomRise is
// one of the apps, so every roundup MUST carry a `disclosure`, MomRise may not
// be listed first, and its drawbacks are rendered just like everyone else's.
//
// Roundup fields (besides the usual slug/headline/subhead/category/published/
// updated/answer/faqs/related/sources):
//   checked       ISO date the app facts were checked (shown above the table)
//   disclosure    { heading, points: [text] }      — required, rendered first
//   notice        text                              — optional callout
//   sectionsBefore / sectionsAfter: [{ id?, heading, paras?: [text], bullets?: [text] }]
//   apps          [{ id, bestFor, note? }]          — display order
//   cta           { lead, body(html) }
//
// Text fields support: [n] page-source citations, {cite:<appId>} (cites that
// app's own sources), [label](/url) links and **bold**.

const fs = require('fs');
const path = require('path');
const {
  SITE, APP_STORE, FOOTER,
  escapeHtml, escapeJson, truncate, stripRefs, fmtDate,
  bylineHtml, sourcesHtml, articleLd, faqLd, relatedHtml, ogTags,
} = require('./aeo-shared');

const STALE_DAYS = 120;

function loadAppGraph(repoRoot) {
  const p = path.join(repoRoot, 'data', 'meal-planning-apps.json');
  const raw = JSON.parse(fs.readFileSync(p, 'utf8'));
  const byId = {};
  for (const a of raw.apps || []) byId[a.id] = a;
  return byId;
}

function validateRoundup(c, graph) {
  const problems = [];
  if (!c.slug || !c.headline) problems.push('missing slug/headline');
  if (!c.disclosure || !(c.disclosure.points || []).length) problems.push('missing disclosure (required: MomRise is a participant)');
  if (!Array.isArray(c.apps) || !c.apps.length) problems.push('no apps');
  for (const e of c.apps || []) {
    const a = graph && graph[e.id];
    if (!a) { problems.push(`unknown app id "${e.id}"`); continue; }
    if (!a.lastVerified) problems.push(`${e.id}: no lastVerified date`);
    if (!(a.sources || []).length) problems.push(`${e.id}: no sources`);
    const age = (Date.parse(c.updated || c.checked) - Date.parse(a.lastVerified)) / 864e5;
    if (age > STALE_DAYS) console.warn(`  ! ${c.slug}: ${e.id} facts are ${Math.round(age)} days old — re-verify`);
  }
  if (c.apps && c.apps[0] && graph && graph[c.apps[0].id] && graph[c.apps[0].id].self) {
    problems.push('MomRise must not be listed first (self-participant guardrail)');
  }
  return problems;
}

// Page sources first (so authored [n] markers stay stable), then each app's
// own sources, de-duplicated by URL.
function combineSources(c, graph) {
  const all = [];
  const index = new Map();
  const add = (s) => {
    const key = s.url || s.title;
    if (!index.has(key)) { all.push(s); index.set(key, all.length); }
    return index.get(key);
  };
  (c.sources || []).forEach(add);
  const appRefs = {};
  for (const e of c.apps) appRefs[e.id] = (graph[e.id].sources || []).map(add);
  return { all, add, appRefs };
}

function supLinks(ids) {
  if (!ids || !ids.length) return '';
  return '<sup class="ref">' + ids.map((i) => `<a href="#source-${i}">[${i}]</a>`).join('') + '</sup>';
}

function makeRich(ctx) {
  const { all, add, appRefs, graph, slug } = ctx;
  return function rich(s) {
    let h = escapeHtml(s);
    h = h.replace(/\{cite:([a-z0-9-]+)\}/g, (_, id) => {
      let refs = appRefs[id];
      if (!refs && graph[id]) refs = appRefs[id] = (graph[id].sources || []).map(add);
      if (!refs) { console.warn(`  ! ${slug}: {cite:${id}} unknown app`); return ''; }
      return supLinks(refs);
    });
    h = h.replace(/\s?\[(\d+(?:\s*,\s*\d+)*)\](?!\()/g, (_, list) => {
      const ids = list.split(',').map((x) => parseInt(x.trim(), 10)).filter((i) => {
        const ok = i >= 1 && i <= all.length;
        if (!ok) console.warn(`  ! ${slug}: citation [${i}] has no matching source`);
        return ok;
      });
      return supLinks(ids);
    });
    h = h.replace(/\[([^\]]+)\]\((\/[^)\s]*|https:\/\/[^)\s]+)\)/g, (_, label, href) => {
      const ext = href.startsWith('https://') ? ' rel="noopener" target="_blank"' : '';
      return `<a href="${href}"${ext}>${label}</a>`;
    });
    h = h.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
    return h;
  };
}

// Plain text for JSON-LD / meta.
function plain(s) {
  return stripRefs(String(s || ''))
    .replace(/\{cite:[a-z0-9-]+\}/g, '')
    .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1')
    .replace(/\*\*([^*]+)\*\*/g, '$1');
}

function sectionHtml(sec, rich) {
  const id = sec.id ? ` id="${escapeHtml(sec.id)}"` : '';
  const paras = (sec.paras || []).map((p) => `\n      <p>${rich(p)}</p>`).join('');
  const bullets = (sec.bullets || []).length
    ? `\n      <ul>${sec.bullets.map((b) => `\n        <li>${rich(b)}</li>`).join('')}\n      </ul>` : '';
  const after = (sec.parasAfter || []).map((p) => `\n      <p>${rich(p)}</p>`).join('');
  return `<section class="rs-section"${id}>
      <h2>${escapeHtml(sec.heading)}</h2>${paras}${bullets}${after}
    </section>`;
}

function itemListLd(c, graph) {
  return {
    '@context': 'https://schema.org',
    '@type': 'ItemList',
    name: c.headline,
    itemListOrder: 'https://schema.org/ItemListUnordered',
    numberOfItems: c.apps.length,
    itemListElement: c.apps.map((e, i) => {
      const a = graph[e.id];
      const item = a.self
        ? { '@type': 'MobileApplication', '@id': `${SITE}/#app`, name: a.name, url: 'https://apps.apple.com/us/app/momrise/id6758357382' }
        : { '@type': 'SoftwareApplication', name: a.name, url: a.url, applicationCategory: 'LifestyleApplication' };
      return { '@type': 'ListItem', position: i + 1, item };
    }),
  };
}

function buildRoundupPage(c, graph) {
  const url = `${SITE}/compare/${c.slug}/`;
  const { all, add, appRefs } = combineSources(c, graph);
  const rich = makeRich({ all, add, appRefs, graph, slug: c.slug });
  const plainDesc = truncate(plain(c.answer), 200);
  const checked = c.checked ? fmtDate(c.checked) : '';
  const checkedMonth = c.checked
    ? new Date(c.checked + 'T00:00:00Z').toLocaleDateString('en-US', { month: 'long', year: 'numeric', timeZone: 'UTC' })
    : '';

  // Render prose first so {cite:x} for unlisted apps registers its sources
  // before the Sources list / JSON-LD citation are built.
  const disclosure = `<aside class="disclosure" aria-label="Disclosure">
      <h2>${escapeHtml(c.disclosure.heading || 'Disclosure: this page is written by MomRise')}</h2>
      <ul>${c.disclosure.points.map((p) => `\n        <li>${rich(p)}</li>`).join('')}
      </ul>
    </aside>`;
  const answer = rich(c.answer);
  const notice = c.notice ? `<p class="notice">${rich(c.notice)}</p>` : '';
  const before = (c.sectionsBefore || []).map((s) => sectionHtml(s, rich)).join('\n    ');

  const picks = c.apps.map((e) => {
    const a = graph[e.id];
    return `\n        <li><span class="when">${rich(e.bestFor)}</span><span class="pick"><a href="#app-${a.id}">${escapeHtml(a.name)}</a>${a.self ? ' <span class="ours">(our app)</span>' : ''}</span></li>`;
  }).join('');

  const rows = c.apps.map((e) => {
    const a = graph[e.id];
    const p = a.price || {};
    const price = [p.freeTier && `<strong>Free plan:</strong> ${escapeHtml(p.freeTier)}`,
      p.trial && p.trial !== '—' && `<strong>Trial:</strong> ${escapeHtml(p.trial)}`,
      `<strong>Monthly:</strong> ${escapeHtml(p.monthly || '—')}`,
      `<strong>Annual:</strong> ${escapeHtml(p.annual || '—')}`].filter(Boolean).join('<br>');
    return `
          <tr${a.self ? ' class="ours-row"' : ''}>
            <th scope="row"><a href="#app-${a.id}">${escapeHtml(a.name)}</a>${a.self ? '<br><span class="ours">(our app)</span>' : ''}${supLinks(appRefs[a.id])}</th>
            <td>${price}</td>
            <td>${escapeHtml(a.platforms || '—')}</td>
            <td>${escapeHtml(a.groceryList || '—')}</td>
            <td>${escapeHtml(a.recipeImport || '—')}</td>
            <td>${escapeHtml(a.kidFeatures || '—')}</td>
            <td>${escapeHtml(a.familySharing || '—')}</td>
          </tr>`;
  }).join('');

  const cards = c.apps.map((e) => {
    const a = graph[e.id];
    const li = (xs) => (xs || []).map((x) => `\n          <li>${escapeHtml(x)}</li>`).join('');
    const p = a.price || {};
    return `<article class="app-card${a.self ? ' ours-card' : ''}" id="app-${a.id}">
        <p class="app-bestfor">${rich(e.bestFor)}</p>
        <h3>${escapeHtml(a.name)}${a.self ? ' <span class="ours">(our app)</span>' : ''}</h3>
        <p><strong>Who it's for:</strong> ${escapeHtml(a.whoFor)}</p>${e.note ? `\n        <p>${rich(e.note)}</p>` : ''}
        <div class="pros-cons">
          <div><h4>Strengths</h4><ul>${li(a.strengths)}
          </ul></div>
          <div><h4>Drawbacks</h4><ul>${li(a.drawbacks)}
          </ul></div>
        </div>
        <p class="app-facts"><strong>Price:</strong> ${escapeHtml(p.summary || '—')} · <strong>Platforms:</strong> ${escapeHtml(a.platforms || '—')} · Checked ${fmtDate(a.lastVerified)}${supLinks(appRefs[a.id])} · <a href="${escapeHtml(a.self ? APP_STORE : a.url)}" rel="noopener" target="_blank">${a.self ? 'App Store' : 'Official site'}</a></p>
      </article>`;
  }).join('\n      ');

  const after = (c.sectionsAfter || []).map((s) => sectionHtml(s, rich)).join('\n    ');
  const faqs = (c.faqs || []).map((f) => `
      <div class="faq-item">
        <h3>${escapeHtml(f.q)}</h3>
        <p>${rich(f.a)}</p>
      </div>`).join('');

  const momrise = Object.values(graph).find((a) => a.self);
  const ctaSub = momrise ? `${escapeHtml(momrise.price.summary)} · iPhone only` : '';

  const article = articleLd({ headline: c.headline, description: plainDesc, url, item: { ...c, sources: all } });
  const faq = faqLd((c.faqs || []).map((f) => ({ q: f.q, a: plain(f.a) })));
  const list = itemListLd(c, graph);

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(c.headline)} — MomRise</title>
  <meta name="description" content="${escapeHtml(plainDesc)}">
  <link rel="canonical" href="${url}">

  ${ogTags({ url, title: c.headline, description: plainDesc })}

  <script type="application/ld+json">
${escapeJson(JSON.stringify(article, null, 2))}
  </script>
  <script type="application/ld+json">
${escapeJson(JSON.stringify(list, null, 2))}
  </script>
  <script type="application/ld+json">
${escapeJson(JSON.stringify(faq, null, 2))}
  </script>

  <link rel="stylesheet" href="/compare/style.css">
  <script src="/static/analytics.js" defer></script>
</head>
<body>
  <header class="page-header">
    <a href="/" class="brand"><span class="brand-mark">MomRise</span></a>
  </header>

  <main class="cmp roundup">
    <p class="eyebrow">${escapeHtml(c.category || 'App comparison')}</p>
    <h1>${escapeHtml(c.headline)}</h1>
    <p class="subhead">${escapeHtml(c.subhead || '')}</p>
    ${bylineHtml(c)}

    ${disclosure}

    <!-- Answer-first: the block AI answer engines quote -->
    <section class="answer" aria-label="Quick answer">
      <h2>Quick answer</h2>
      <p>${answer}</p>
    </section>
    ${notice}
    ${before}

    <section class="best-for">
      <h2>${escapeHtml(c.picksHeading || 'Our picks by need')}</h2>
      <ul>${picks}
      </ul>
    </section>

    <section class="table-wrap">
      <h2>Side-by-side comparison</h2>
      <p class="checked">Prices and features checked ${escapeHtml(checked)} against each app's own website, help pages or App Store listing. "—" means we couldn't confirm it there. Prices are in USD and can change; in-app prices sometimes differ from website prices.</p>
      <table class="cmp-table apps-table">
        <thead>
          <tr><th scope="col">App</th><th scope="col">Price</th><th scope="col">Platforms</th><th scope="col">Grocery list</th><th scope="col">Recipe import</th><th scope="col">Kid / picky-eater features</th><th scope="col">Family sharing</th></tr>
        </thead>
        <tbody>${rows}
        </tbody>
      </table>
    </section>

    <section class="app-cards">
      <h2>${escapeHtml(c.cardsHeading || 'The apps, one by one')}</h2>
      ${cards}
    </section>

    ${after}

    <div class="cta">
      <p class="cta-lead">${escapeHtml((c.cta && c.cta.lead) || 'Want meal planning and the rest of family life in one app?')}</p>
      <p>${(c.cta && c.cta.body) || 'MomRise plans the week\'s meals, builds the grocery list, and keeps milestones, activities and the family calendar alongside it.'}</p>
      <div class="app-buttons">
        <a class="store-btn" href="${APP_STORE}">Download on the App Store</a>
      </div>
      <p class="cta-sub">${ctaSub}</p>
    </div>

    <section class="faq">
      <h2>Frequently asked questions</h2>${faqs}
    </section>

    ${relatedHtml(c.related, 'Related')}
    <p class="disclaimer">${escapeHtml(c.disclaimer || `App names and trademarks belong to their owners. None of these companies paid to be included, and this page has no affiliate links. Facts were checked ${checkedMonth}; if something has changed, email hi@momrise.app and we'll correct it.`)}</p>
    ${sourcesHtml(all)}
  </main>

  ${FOOTER}
</body>
</html>
`;
}

module.exports = { loadAppGraph, validateRoundup, buildRoundupPage };
