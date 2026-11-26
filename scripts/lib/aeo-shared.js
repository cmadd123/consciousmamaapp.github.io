// Shared helpers for the data-driven AEO page generators
// (generate-comparison-pages.js, generate-answer-pages.js).
//
// Trust layer for health-adjacent (YMYL) content:
//   - sources:   [{ title, publisher, url }] rendered as a numbered "Sources"
//                list + Article JSON-LD `citation`. Copy fields may reference
//                a source inline with a [n] marker (1-based), which renders as
//                a superscript link to that entry.
//   - published / updated: ISO dates -> Article datePublished/dateModified and
//                a visible "Published … · Updated …" line.
//   - reviewer:  OPTIONAL { name, credentials } -> "Medically reviewed by" line
//                + JSON-LD reviewedBy. Rendered ONLY when set. Never invent one.

const SITE = 'https://momrise.app';
const APP_STORE = 'https://apps.apple.com/app/id6758357382';
const PLAY_STORE = 'https://play.google.com/store/apps/details?id=com.momrise.app';
const OG_IMAGE = `${SITE}/app_store_assets/brand/momrise-icon-square-512.png`;

function escapeHtml(s) {
  return String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;').replace(/'/g, '&#039;');
}
function escapeJson(s) {
  return String(s == null ? '' : s).replace(/<\/script/gi, '<\/script');
}
function truncate(s, n) {
  s = String(s || '').trim();
  return s.length > n ? s.slice(0, n - 1).trimEnd() + '…' : s;
}

// [n] / [n,m] citation markers.
const REF_RE = /\s?\[(\d+(?:\s*,\s*\d+)*)\]/g;

// Plain text for meta tags + JSON-LD: drop the markers.
function stripRefs(s) {
  return String(s == null ? '' : s).replace(REF_RE, '');
}

// Escaped HTML with markers turned into superscript links to #source-n.
// Markers pointing at a source that doesn't exist are dropped (and warned).
function withRefs(s, sources, ctx) {
  const n = Array.isArray(sources) ? sources.length : 0;
  return escapeHtml(s).replace(REF_RE, (_, list) => {
    const ids = list.split(',').map((x) => parseInt(x.trim(), 10))
      .filter((i) => {
        const ok = i >= 1 && i <= n;
        if (!ok) console.warn(`  ! ${ctx || ''}: citation [${i}] has no matching source`);
        return ok;
      });
    if (!ids.length) return '';
    return '<sup class="ref">' + ids.map((i) => `<a href="#source-${i}">[${i}]</a>`).join('') + '</sup>';
  });
}

function fmtDate(iso) {
  if (!iso) return '';
  const d = new Date(iso + 'T00:00:00Z');
  if (isNaN(d)) return iso;
  return d.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric', timeZone: 'UTC' });
}

// Visible byline: dates + optional reviewer.
function bylineHtml(item) {
  const parts = [];
  if (item.published) parts.push(`Published <time datetime="${escapeHtml(item.published)}">${fmtDate(item.published)}</time>`);
  if (item.updated) parts.push(`Updated <time datetime="${escapeHtml(item.updated)}">${fmtDate(item.updated)}</time>`);
  const dates = parts.length ? `<p class="byline">${parts.join(' · ')}</p>` : '';
  const r = item.reviewer;
  const reviewer = r && r.name
    ? `\n    <p class="reviewed">Medically reviewed by ${escapeHtml(r.name)}${r.credentials ? `, ${escapeHtml(r.credentials)}` : ''}</p>`
    : '';
  return dates + reviewer;
}

function normSource(s) {
  return typeof s === 'string' ? { title: s } : (s || {});
}

function sourcesHtml(sources) {
  if (!Array.isArray(sources) || !sources.length) return '';
  const lis = sources.map((raw, i) => {
    const s = normSource(raw);
    const title = s.url
      ? `<a href="${escapeHtml(s.url)}" rel="noopener" target="_blank">${escapeHtml(s.title)}</a>`
      : escapeHtml(s.title);
    const pub = s.publisher ? ` — ${escapeHtml(s.publisher)}` : '';
    return `\n        <li id="source-${i + 1}">${title}${pub}</li>`;
  }).join('');
  return `<section class="sources" aria-label="Sources">
      <h2>Sources</h2>
      <ol>${lis}
      </ol>
    </section>`;
}

function citationLd(sources) {
  return (sources || []).map(normSource).filter((s) => s.title).map((s) => {
    const c = { '@type': 'CreativeWork', name: s.title };
    if (s.publisher) c.publisher = { '@type': 'Organization', name: s.publisher };
    if (s.url) c.url = s.url;
    return c;
  });
}

// Article JSON-LD shared by both page types.
function articleLd({ headline, description, url, item }) {
  const article = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline,
    description,
    author: { '@type': 'Organization', name: 'MomRise', url: SITE },
    publisher: { '@type': 'Organization', name: 'MomRise', url: SITE },
  };
  if (item.published) article.datePublished = item.published;
  if (item.updated) article.dateModified = item.updated;
  article.image = OG_IMAGE;
  // reviewedBy is a WebPage property in schema.org, so it rides on
  // mainEntityOfPage — and only when a real reviewer is set in the data.
  const r = item.reviewer;
  if (r && r.name) {
    const person = { '@type': 'Person', name: r.name };
    if (r.credentials) person.jobTitle = r.credentials;
    article.mainEntityOfPage = { '@type': 'WebPage', '@id': url, reviewedBy: person, lastReviewed: r.date || item.updated };
  } else {
    article.mainEntityOfPage = url;
  }
  article.url = url;
  const citation = citationLd(item.sources);
  if (citation.length) article.citation = citation;
  return article;
}

function faqLd(faqs) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: (faqs || []).map((f) => ({
      '@type': 'Question',
      name: stripRefs(f.q),
      acceptedAnswer: { '@type': 'Answer', text: stripRefs(f.a) },
    })),
  };
}

function relatedHtml(related, heading) {
  if (!Array.isArray(related) || !related.length) return '';
  const lis = related.map((r) => `\n        <li><a href="${escapeHtml(r.url)}">${escapeHtml(r.title)}</a></li>`).join('');
  return `<section class="related">
      <h2>${escapeHtml(heading)}</h2>
      <ul>${lis}
      </ul>
    </section>`;
}

function ogTags({ url, title, description, type }) {
  return `<meta property="og:type" content="${type || 'article'}">
  <meta property="og:site_name" content="MomRise">
  <meta property="og:url" content="${url}">
  <meta property="og:title" content="${escapeHtml(title)}">
  <meta property="og:description" content="${escapeHtml(description)}">
  <meta property="og:image" content="${OG_IMAGE}">`;
}

const FOOTER = `<footer class="page-footer">
    <a href="/">MomRise</a> · <a href="/meal-ideas/">Meal ideas</a> · <a href="/answers/">Answers</a> · <a href="/compare/">Compare</a> · <a href="/about/">About &amp; editorial standards</a> · <a href="/privacy.html">Privacy</a>
  </footer>`;

module.exports = {
  SITE, APP_STORE, PLAY_STORE, OG_IMAGE, FOOTER,
  escapeHtml, escapeJson, truncate, stripRefs, withRefs, fmtDate,
  bylineHtml, sourcesHtml, citationLd, articleLd, faqLd, relatedHtml, ogTags,
};
