// Generates Pinterest-Rich-Pin-ready landing pages at r/{slug}/index.html
// for every recipe in Firestore where `is_curated == true`.
//
// Run from the repo root:
//   node scripts/generate-recipe-pages.js              # generate to r/
//   node scripts/generate-recipe-pages.js --dry-run    # log what would generate
//   node scripts/generate-recipe-pages.js --recipe ID  # one specific recipe (debugging)
//
// Output: r/{slug}/index.html per recipe + r/index.html (catalog page).
// Idempotent. Re-running overwrites stale pages.

const admin = require('firebase-admin');
const https = require('https');
const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const outRoot = path.join(repoRoot, 'r');
const saPath = path.join(repoRoot, 'admin', 'service-account.json');

const dryRun = process.argv.includes('--dry-run');
const noRewrite = process.argv.includes('--no-rewrite');
const forceRewrite = process.argv.includes('--force-rewrite');
const oneRecipeIdx = process.argv.indexOf('--recipe');
const oneRecipeId = oneRecipeIdx > -1 ? process.argv[oneRecipeIdx + 1] : null;

admin.initializeApp({ credential: admin.credential.cert(require(saPath)) });
const db = admin.firestore();

// OpenAI key sourced from Firebase Remote Config (parameter name
// `openai_api_key`, matching how the Flutter app reads it). Env var
// OPENAI_API_KEY overrides if set. Resolved lazily so --no-rewrite skips
// the fetch entirely.
let _openaiKey = null;
async function getOpenAIKey() {
  if (_openaiKey !== null) return _openaiKey;
  if (process.env.OPENAI_API_KEY) {
    _openaiKey = process.env.OPENAI_API_KEY.trim();
    return _openaiKey;
  }
  const template = await admin.remoteConfig().getTemplate();
  const param = template.parameters?.openai_api_key;
  const defaultVal = param?.defaultValue;
  const value = (defaultVal && 'value' in defaultVal) ? String(defaultVal.value).trim() : '';
  if (!value) {
    throw new Error('Remote Config has no `openai_api_key` parameter (or it is empty).');
  }
  _openaiKey = value;
  return _openaiKey;
}

// ---------- helpers ----------

function kebab(s) {
  return String(s || '')
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .slice(0, 60);
}

function escapeHtml(s) {
  return String(s || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function escapeJson(s) {
  // For embedding inside <script type="application/ld+json"> — only need
  // to escape </script> sequences and control characters. JSON.stringify
  // handles most of it; we just guard the script-tag escape.
  return String(s || '').replace(/<\/script/gi, '<\\/script');
}

function isoDuration(minutes) {
  const m = Math.max(0, Math.round(Number(minutes) || 0));
  return `PT${m}M`;
}

function slugFor(recipe, docId) {
  const shortId = docId.slice(-6);
  return `${kebab(recipe.recipe_name)}-${shortId}` || `recipe-${shortId}`;
}

function truncate(s, n) {
  s = String(s || '').trim();
  return s.length > n ? s.slice(0, n - 1).trimEnd() + '…' : s;
}

// Extract a clean, human-readable host from a URL. Strips www. and any
// trailing path. Falls back to the raw string if URL parsing fails.
function sourceDomain(url) {
  try {
    return new URL(String(url)).hostname.replace(/^www\./, '');
  } catch {
    return String(url || '').replace(/^https?:\/\//i, '').replace(/^www\./i, '').split('/')[0];
  }
}

// LLM rewrite of cooking instructions in MomRise's voice. Same recipe,
// our prose — turns verbatim republication into genuine adaptation,
// which is the load-bearing copyright posture for the /r/ pages.
//
// Caches result in Firestore so we don't re-pay on every regen. Pass
// --force-rewrite to bypass cache. Pass --no-rewrite to publish verbatim
// (legacy behavior, not recommended).
async function rewriteInstructions(steps, recipeName) {
  const key = await getOpenAIKey();
  const prompt = `Rewrite these recipe instructions in a warm, concise voice suitable for a parenting/meal-planning app. Same recipe — same ingredients, same equipment, same order, same temperatures and times. Different words.

RECIPE: ${recipeName}

ORIGINAL STEPS:
${steps.map((s, i) => `${i + 1}. ${s}`).join('\n')}

RULES:
- Return EXACTLY the same number of steps as input. Each step covers the same action; only the words change.
- Drop any preamble, brand mentions, life stories, asides, or "make sure to scroll past" filler from the original.
- Keep concrete details: temperatures, times, sizes, equipment.
- Voice: friendly and direct, like a mom showing another mom. No corporate copy. No "you'll love how easy this is!" filler.
- Avoid mirroring the original sentence structure too closely. Vary openings.
- Each step under 30 words when possible.

Return ONLY valid JSON in this shape, no prose, no markdown fences:
{ "steps": ["rewritten step 1", "rewritten step 2", ...] }`;

  const body = JSON.stringify({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: 'You rewrite recipe instructions in a friendly parenting-app voice. Same recipe, our prose. Return only valid JSON.' },
      { role: 'user', content: prompt },
    ],
    temperature: 0.4,
    max_tokens: 1500,
    response_format: { type: 'json_object' },
  });

  const raw = await new Promise((resolve, reject) => {
    const req = https.request('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${key}`,
        'Content-Length': Buffer.byteLength(body),
      },
    }, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        if (res.statusCode !== 200) return reject(new Error(`OpenAI ${res.statusCode}: ${data.substring(0, 300)}`));
        resolve(data);
      });
    });
    req.on('error', reject);
    req.setTimeout(45000, () => { req.destroy(); reject(new Error('OpenAI timeout')); });
    req.write(body);
    req.end();
  });

  const parsed = JSON.parse(raw);
  const content = parsed.choices?.[0]?.message?.content;
  if (!content) throw new Error('No content in OpenAI response');
  const out = JSON.parse(content);
  if (!Array.isArray(out.steps) || out.steps.length === 0) throw new Error('LLM returned no steps');
  return out.steps.map((s) => String(s).trim()).filter(Boolean);
}

// ---------- page template ----------

function buildSchema(recipe, slug) {
  const ingredients = Array.isArray(recipe.ingredients) ? recipe.ingredients.filter(Boolean) : [];
  const instructions = Array.isArray(recipe.CookingInstructions) ? recipe.CookingInstructions.filter(Boolean) : [];
  const prep = Number(recipe.prepare_time) || 0;
  const cook = Number(recipe.cooking_time) || 0;
  const total = prep + cook;

  const schema = {
    '@context': 'https://schema.org',
    '@type': 'Recipe',
    name: recipe.recipe_name || 'Recipe',
    image: recipe.image_url ? [recipe.image_url] : [],
    description: truncate(recipe.recipe_name + (recipe.meal_typ ? ` — ${recipe.meal_typ}` : ''), 200),
    author: { '@type': 'Organization', name: 'MomRise' },
    recipeYield: '4 servings',
    recipeCategory: recipe.meal_typ || 'Main Course',
    recipeCuisine: 'American',
    prepTime: isoDuration(prep),
    cookTime: isoDuration(cook),
    totalTime: isoDuration(total),
    recipeIngredient: ingredients,
    recipeInstructions: instructions.map((text) => ({ '@type': 'HowToStep', text })),
    url: `https://momrise.app/r/${slug}/`,
  };

  // Attribution to original source — required for legal posture when
  // recipes come from third-party sites. Pinterest doesn't care, but
  // copyright defense does.
  if (recipe.source_url) {
    schema.isBasedOn = {
      '@type': 'CreativeWork',
      url: recipe.source_url,
      name: sourceDomain(recipe.source_url),
    };
  }

  return JSON.stringify(schema, null, 2);
}

// Answer-first FAQ, derived deterministically from the recipe's own data
// (times, servings, ingredient count) — no AI, no fluff. This is the block
// LLMs and AI answer-engines quote, and it naturally funnels "how do I meal
// plan X" queries into the app.
function buildFaqs(recipe) {
  const name = recipe.recipe_name || 'this recipe';
  const prep = Math.round(Number(recipe.prepare_time) || 0);
  const cook = Math.round(Number(recipe.cooking_time) || 0);
  const total = prep + cook;
  const nIng = (Array.isArray(recipe.ingredients) ? recipe.ingredients.filter(Boolean) : []).length;
  const faqs = [];

  if (total > 0) {
    faqs.push({
      q: `How long does ${name} take to make?`,
      a: `About ${total} minutes total${prep && cook ? ` — roughly ${prep} minutes of prep and ${cook} minutes of cooking` : ''}.`,
    });
  }
  faqs.push({
    q: `How many servings does ${name} make?`,
    a: `It makes about 4 servings — enough for a family dinner, give or take depending on ages and appetites.`,
  });
  if (nIng > 0) {
    faqs.push({
      q: `What do I need to make ${name}?`,
      a: `${nIng} ingredient${nIng === 1 ? '' : 's'} — the full list is above, and most are common pantry and fridge staples.`,
    });
  }
  faqs.push({
    q: `Can I add ${name} to a weekly meal plan?`,
    a: `Yes — open ${name} in the free MomRise app to save it to your weekly plan, auto-build the grocery list, and plan the rest of the week in a few taps.`,
  });
  return faqs;
}

function buildFaqSchema(faqs) {
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: faqs.map((f) => ({
      '@type': 'Question',
      name: f.q,
      acceptedAnswer: { '@type': 'Answer', text: f.a },
    })),
  };
  return JSON.stringify(schema, null, 2);
}

function buildPage(recipe, slug, docId) {
  const name = escapeHtml(recipe.recipe_name || 'Recipe');
  const image = escapeHtml(recipe.image_url || '');
  const description = escapeHtml(truncate(`${recipe.recipe_name || 'Recipe'} from MomRise — meal-plan it in one tap.`, 200));
  const ingredients = (Array.isArray(recipe.ingredients) ? recipe.ingredients : []).filter(Boolean);
  const instructions = (Array.isArray(recipe.CookingInstructions) ? recipe.CookingInstructions : []).filter(Boolean);
  const prep = Math.round(Number(recipe.prepare_time) || 0);
  const cook = Math.round(Number(recipe.cooking_time) || 0);
  const schemaJson = escapeJson(buildSchema(recipe, slug));
  const faqs = buildFaqs(recipe);
  const faqSchemaJson = escapeJson(buildFaqSchema(faqs));
  const deepLink = `momrise://r/${slug}`;
  const sourceUrl = recipe.source_url ? escapeHtml(recipe.source_url) : '';
  const sourceDom = recipe.source_url ? escapeHtml(sourceDomain(recipe.source_url)) : '';

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${name} — MomRise</title>
  <meta name="description" content="${description}">
  <link rel="canonical" href="https://momrise.app/r/${slug}/">

  <meta property="og:type" content="article">
  <meta property="og:site_name" content="MomRise">
  <meta property="og:url" content="https://momrise.app/r/${slug}/">
  <meta property="og:title" content="${name}">
  <meta property="og:description" content="${description}">
  ${image ? `<meta property="og:image" content="${image}">` : ''}

  <meta name="apple-itunes-app" content="app-id=6758357382, app-argument=${deepLink}">

  <script type="application/ld+json">
${schemaJson}
  </script>

  <script type="application/ld+json">
${faqSchemaJson}
  </script>

  <link rel="stylesheet" href="/r/style.css">
</head>
<body>
  <header class="page-header">
    <a href="/" class="brand">
      <span class="brand-mark">MomRise</span>
    </a>
  </header>

  <main class="recipe">
    ${image ? `<div class="hero"><img src="${image}" alt="${name}" loading="eager"></div>` : ''}

    <h1>${name}</h1>

    ${sourceUrl ? `<p class="attribution">Adapted from <a href="${sourceUrl}" rel="noopener nofollow" target="_blank">${sourceDom}</a></p>` : ''}

    <div class="stats">
      ${prep ? `<div><span class="label">Prep</span><span class="value">${prep} min</span></div>` : ''}
      ${cook ? `<div><span class="label">Cook</span><span class="value">${cook} min</span></div>` : ''}
      <div><span class="label">Serves</span><span class="value">4</span></div>
    </div>

    <div class="cta-primary">
      <a class="open-in-app" href="${deepLink}" data-fallback="https://apps.apple.com/app/id6758357382">
        Open this recipe in MomRise
      </a>
      <p class="cta-sub">Free 7-day trial · No credit card</p>
    </div>

    <section class="ingredients">
      <h2>Ingredients</h2>
      <ul>
        ${ingredients.map((i) => `<li>${escapeHtml(i)}</li>`).join('\n        ')}
      </ul>
    </section>

    <section class="instructions">
      <h2>Instructions</h2>
      <ol>
        ${instructions.map((s) => `<li>${escapeHtml(s)}</li>`).join('\n        ')}
      </ol>
    </section>

    <section class="faq">
      <h2>Common questions</h2>
      ${faqs.map((f) => `<div class="faq-item">
        <h3>${escapeHtml(f.q)}</h3>
        <p>${escapeHtml(f.a)}</p>
      </div>`).join('\n      ')}
    </section>

    <div class="cta-secondary">
      <p>Plan this for the week — and never lose another recipe.</p>
      <div class="app-buttons">
        <a class="store-btn" href="https://apps.apple.com/app/id6758357382">App Store</a>
        <a class="store-btn" href="https://play.google.com/store/apps/details?id=com.momrise.app">Google Play</a>
      </div>
    </div>
  </main>

  <footer class="page-footer">
    <a href="/">MomRise</a> · <a href="/creator/">Creators</a> · <a href="/privacy.html">Privacy</a>
  </footer>

  <script>
    // Pinterest install attribution. If the user came from a pin, log a
    // page view tagged so we can correlate to installs in Firebase
    // Analytics later. The cookie-less version is sufficient for now.
    (function () {
      const p = new URLSearchParams(location.search);
      const src = p.get('src');
      if (src) {
        try { localStorage.setItem('mr_attribution', JSON.stringify({ src, board: p.get('board') || '', at: Date.now() })); } catch (e) {}
      }

      // App-deep-link fallback: tapping "Open in MomRise" tries the
      // momrise:// scheme; if nothing handles it after ~700ms we send
      // the user to the App Store. Safari/iOS will silently swallow
      // the failed deep link, so the timer is the signal.
      const btn = document.querySelector('.open-in-app');
      if (btn) {
        btn.addEventListener('click', function (e) {
          const fallback = btn.getAttribute('data-fallback');
          const start = Date.now();
          setTimeout(function () {
            if (Date.now() - start < 1200 && document.visibilityState === 'visible') {
              location.href = fallback;
            }
          }, 700);
        });
      }
    })();
  </script>
</body>
</html>
`;
}

// ---------- main ----------

(async () => {
  console.log(dryRun ? 'DRY RUN — nothing will be written.' : 'Generating recipe pages…');

  let snap;
  if (oneRecipeId) {
    const doc = await db.collection('meal').doc(oneRecipeId).get();
    if (!doc.exists) {
      console.error(`No recipe found with id ${oneRecipeId}`);
      process.exit(1);
    }
    snap = { docs: [doc], size: 1 };
  } else {
    snap = await db.collection('meal').where('is_curated', '==', true).get();
  }

  console.log(`Found ${snap.size} curated recipe(s).`);
  if (snap.size === 0) {
    console.log('Nothing to generate. (Set `is_curated: true` on recipes in Firestore to publish them.)');
    process.exit(0);
  }

  if (!dryRun) fs.mkdirSync(outRoot, { recursive: true });

  let wrote = 0;
  let skipped = 0;
  let rewriteCalls = 0;
  let rewriteCached = 0;
  let rewriteFailures = 0;
  const catalog = [];
  for (const doc of snap.docs) {
    const recipe = doc.data();
    if (!recipe.recipe_name) {
      skipped++;
      console.log(`  · Skip ${doc.id}: no recipe_name`);
      continue;
    }
    if (!Array.isArray(recipe.ingredients) || recipe.ingredients.length === 0) {
      skipped++;
      console.log(`  · Skip ${doc.id} (${recipe.recipe_name}): no ingredients`);
      continue;
    }
    if (!Array.isArray(recipe.CookingInstructions) || recipe.CookingInstructions.length === 0) {
      skipped++;
      console.log(`  · Skip ${doc.id} (${recipe.recipe_name}): no instructions`);
      continue;
    }

    // Rewrite instructions for legal posture. Cached in Firestore as
    // `web_instructions`; bypassed with --force-rewrite, skipped with
    // --no-rewrite (verbatim with attribution only).
    let webInstructions = Array.isArray(recipe.web_instructions) ? recipe.web_instructions : null;
    if (!noRewrite && (!webInstructions || forceRewrite)) {
      try {
        const fresh = await rewriteInstructions(recipe.CookingInstructions, recipe.recipe_name);
        webInstructions = fresh;
        if (!dryRun) {
          await doc.ref.update({
            web_instructions: fresh,
            web_instructions_at: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
        rewriteCalls++;
        console.log(`  ↻ Rewrote ${recipe.recipe_name} (${fresh.length} steps)`);
      } catch (e) {
        console.warn(`  ! Rewrite failed for ${recipe.recipe_name}: ${e.message}`);
        rewriteFailures++;
        // Skip publishing this recipe rather than falling back to the
        // verbatim instructions — we don't want to publish unrewritten
        // third-party content even on a single failure.
        skipped++;
        continue;
      }
    } else if (webInstructions && !forceRewrite) {
      rewriteCached++;
    }

    // Build the page using web_instructions if available (or original if
    // --no-rewrite explicitly opted in to verbatim publication).
    const renderRecipe = {
      ...recipe,
      CookingInstructions: webInstructions || recipe.CookingInstructions,
    };

    const slug = slugFor(renderRecipe, doc.id);
    const html = buildPage(renderRecipe, slug, doc.id);
    catalog.push({ slug, name: recipe.recipe_name, image: recipe.image_url || '' });

    if (dryRun) {
      console.log(`  ⇢ would write r/${slug}/index.html  (${html.length} bytes)`);
    } else {
      const dir = path.join(outRoot, slug);
      fs.mkdirSync(dir, { recursive: true });
      fs.writeFileSync(path.join(dir, 'index.html'), html, 'utf8');
      console.log(`  ✓ r/${slug}/index.html`);
    }
    wrote++;
  }

  // Catalog index — a no-frills listing so anyone hitting /r/ sees pages
  // exist (and so search engines can crawl them).
  if (!dryRun && catalog.length > 0) {
    const catalogHtml = `<!DOCTYPE html>
<html lang="en"><head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Recipes — MomRise</title>
  <meta name="description" content="Recipes you can save to your MomRise meal plan.">
  <link rel="canonical" href="https://momrise.app/r/">
  <link rel="stylesheet" href="/r/style.css">
</head><body>
  <header class="page-header"><a href="/" class="brand"><span class="brand-mark">MomRise</span></a></header>
  <main class="catalog">
    <h1>Recipes</h1>
    <p class="catalog-sub">Tap any recipe to open it in MomRise.</p>
    <ul class="grid">
      ${catalog.map(c => `<li><a href="/r/${c.slug}/">${c.image ? `<img src="${escapeHtml(c.image)}" alt="">` : ''}<span>${escapeHtml(c.name)}</span></a></li>`).join('\n      ')}
    </ul>
  </main>
  <footer class="page-footer"><a href="/">MomRise</a></footer>
</body></html>
`;
    fs.writeFileSync(path.join(outRoot, 'index.html'), catalogHtml, 'utf8');
    console.log(`  ✓ r/index.html (catalog of ${catalog.length})`);
  }

  console.log(`\nDone. Wrote ${wrote}, skipped ${skipped}.`);
  if (!noRewrite) {
    console.log(`Rewrite: ${rewriteCalls} new, ${rewriteCached} cached, ${rewriteFailures} failed.`);
    if (rewriteCalls > 0) {
      const est = (rewriteCalls * 0.0005).toFixed(3);
      console.log(`Estimated OpenAI cost: ~$${est}`);
    }
  }
  process.exit(0);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
