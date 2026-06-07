# Pinterest Recipe Pages — Phase 1 Build Spec

Build a server-rendered (or pre-generated) page at `momrise.app/r/{slug}/`
for every published recipe. Each page is the Pinterest Rich Pin landing
target AND a working install funnel.

Once this ships, Pinterest becomes a real organic install channel.
Until then, it's a placeholder.

---

## 1. Goals (in priority order)

1. **Get on Pinterest Rich Pins.** Submit one page to Pinterest's URL
   Debugger, get the domain approved, every future `/r/*` page automatically
   becomes a Rich Pin.
2. **Convert Pinterest searchers to app installs.** Page must have a
   working "Open in MomRise" CTA that deep-links into the app if
   installed, App Store / Play Store fallback if not.
3. **Be cheap to operate.** No server cost per page view. No manual
   curation step that doesn't scale.

Non-goals for Phase 1:
- Looking polished as a recipe blog. We don't need to compete with
  AllRecipes. We need ingredients + cook time visible to Pinterest's
  scraper and a working install button. Phase 2 can polish.
- Supporting every recipe in the database. Phase 1 ships with a
  `published_to_web` flag controlling which recipes get pages. Haley +
  Collin curate the first 50-100. Later we open this up.

---

## 2. Route + rendering strategy

**Route**: `momrise.app/r/{slug}/` where `slug = {recipe-name-kebab-case}-{shortId}`
- Example: `momrise.app/r/sheet-pan-chicken-broccoli-x7k9p2/`
- The short ID (last 6 chars of the Firestore doc ID) prevents slug
  collisions and makes the URL canonical even if two recipes share a name.

**Rendering**: **static pre-generation at build time**, not dynamic Cloud
Function.

Reasoning:
- GitHub Pages is the existing host. Free, fast CDN-backed.
- No new infrastructure (no Cloud Function cold starts, no Cloud Run).
- Pinterest's crawler and end users get instant page load.
- Tradeoff: recipes update only when the build runs. For Phase 1 this is
  fine — recipes don't change often.

Implementation:
- New script at `scripts/generate-recipe-pages.js`
- Reads from Firestore collection `recipes` where `published_to_web == true`
- For each recipe, generates `r/{slug}/index.html` with full schema
- Gitignored at first; eventually wire into Codemagic's static.yml build
  so it runs on push

For Phase 1, run the script manually (`node scripts/generate-recipe-pages.js`)
and commit the output. Wire into CI in Phase 1.5.

---

## 3. HTML page structure

### 3a. Head

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{recipe.name} — MomRise</title>
  <meta name="description" content="{recipe.description, truncated to 160 chars}">

  <!-- Canonical -->
  <link rel="canonical" href="https://momrise.app/r/{slug}/">

  <!-- Open Graph (used by IG share + general link previews) -->
  <meta property="og:type" content="article">
  <meta property="og:site_name" content="MomRise">
  <meta property="og:url" content="https://momrise.app/r/{slug}/">
  <meta property="og:title" content="{recipe.name}">
  <meta property="og:description" content="{recipe.description}">
  <meta property="og:image" content="{recipe.imageUrl}">

  <!-- iOS / Android smart banners -->
  <meta name="apple-itunes-app" content="app-id=6758357382, app-argument=momrise://r/{slug}">
  <!-- Android: handled via the install CTA button using intent:// -->

  <!-- Recipe schema (THE Pinterest Rich Pin source) -->
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Recipe",
    "name": "{recipe.name}",
    "image": ["{recipe.imageUrl}"],
    "description": "{recipe.description}",
    "author": {
      "@type": "Person",
      "name": "{recipe.author || 'MomRise'}"
    },
    "datePublished": "{recipe.created_at as ISO 8601}",
    "prepTime": "PT{recipe.prepTime}M",
    "cookTime": "PT{recipe.cookTime}M",
    "totalTime": "PT{recipe.prepTime + recipe.cookTime}M",
    "recipeYield": "{recipe.servings} servings",
    "recipeCategory": "{recipe.category || 'Main Course'}",
    "recipeCuisine": "{recipe.cuisine || 'American'}",
    "recipeIngredient": [
      "{ingredient 1 with quantity}",
      "{ingredient 2 with quantity}",
      ...
    ],
    "recipeInstructions": [
      { "@type": "HowToStep", "text": "{step 1 text}" },
      { "@type": "HowToStep", "text": "{step 2 text}" },
      ...
    ]
  }
  </script>

  <!-- Brand stylesheet -->
  <link rel="stylesheet" href="/r/style.css">
</head>
```

### 3b. Body

```html
<body>
  <!-- Minimal header -->
  <header class="recipe-header">
    <a href="/" class="brand-link">
      <img src="/r/momrise-logo.svg" alt="MomRise" height="32">
    </a>
  </header>

  <main class="recipe-main">
    <!-- Hero image -->
    <div class="hero">
      <img src="{recipe.imageUrl}" alt="{recipe.name}" loading="eager">
    </div>

    <h1>{recipe.name}</h1>

    <p class="description">{recipe.description}</p>

    <!-- Quick stats: visible AND in schema -->
    <div class="stats">
      <div><span class="label">Prep</span><span class="value">{prepTime} min</span></div>
      <div><span class="label">Cook</span><span class="value">{cookTime} min</span></div>
      <div><span class="label">Serves</span><span class="value">{servings}</span></div>
    </div>

    <!-- Primary CTA: top of page, the install funnel entry -->
    <div class="cta-primary">
      <a href="momrise://r/{slug}" class="open-in-app">
        Open this recipe in MomRise
      </a>
      <p class="cta-subtitle">Free 7-day trial. No credit card.</p>
    </div>

    <!-- Ingredients -->
    <section class="ingredients">
      <h2>Ingredients</h2>
      <ul>
        {ingredient list}
      </ul>
    </section>

    <!-- Instructions -->
    <section class="instructions">
      <h2>Instructions</h2>
      <ol>
        {step list}
      </ol>
    </section>

    <!-- Secondary CTA: after instructions -->
    <div class="cta-secondary">
      <p>Plan this for the week — and never lose another recipe.</p>
      <div class="app-buttons">
        <a href="https://apps.apple.com/app/id6758357382">App Store</a>
        <a href="https://play.google.com/store/apps/details?id=com.momrise.app">Google Play</a>
      </div>
    </div>

    <!-- Attribution if creator-sourced -->
    {% if recipe.source_creator %}
      <p class="attribution">Recipe by @{recipe.source_creator}</p>
    {% endif %}
  </main>

  <footer class="recipe-footer">
    <a href="/">MomRise</a> · <a href="/creator/">Creators</a> · <a href="/privacy">Privacy</a>
  </footer>

  <!-- Analytics ping with src= param awareness -->
  <script>
    // Track Pinterest referral (logged to Firebase Analytics)
    const params = new URLSearchParams(window.location.search);
    if (params.get('src') === 'pinterest') {
      // fire pageview event with utm-style attribution
    }
  </script>
</body>
</html>
```

### 3c. Styles

Single shared stylesheet at `/r/style.css`:
- MomRise gradient header (teal → pink as on existing pages)
- Andika New Basic font (consistent with app)
- Mobile-first: target Pinterest mobile users
- Recipe card with clear sections
- Primary CTA = brand pink, large, sticky-feeling
- Max width 720px for readability
- 1-2 KB of CSS — keep it lean

---

## 4. Firestore changes

### 4a. New field on `recipes/{id}`

```
published_to_web: boolean     // defaults false; admin/creator opts in
web_slug: string              // generated when published
web_published_at: timestamp   // when generation happened
```

### 4b. Firestore rules

Update `firestore.rules` for the `recipes` collection:
- Public read should still be limited to user-owned recipes via existing
  rule (don't expose private recipes to web scraping)
- The `generate-recipe-pages.js` script uses Admin SDK so it bypasses
  rules — fine
- For client-side reads on the rendered HTML pages: no Firestore needed,
  data is baked into the static HTML

### 4c. Slug uniqueness

Pre-flight check in the script:
- Kebab-case the name
- Append last 6 chars of doc ID
- Verify no collision (almost zero chance given 6-char tail)

---

## 5. The pin generator tool (admin first, creator dashboard later)

For Phase 1, build a simple admin tool at `admin/pin-generator.html`:

- Lists all `recipes` where `published_to_web == false`
- Each row: thumbnail, name, "Publish" button
- On publish: writes `published_to_web: true` + slug to Firestore
- Shows the generated URL for copy-paste
- Includes a "Download pin image" button (Phase 1: opens a Canva
  template URL with the recipe photo and name pre-populated;
  Phase 2: auto-generates via HTML-to-image)

For Phase 1, the image generation step is manual via Canva. Worth it:
the 30 minutes saved per pin batch in Phase 2 isn't worth the engineering
time until we know Pinterest is converting.

---

## 6. Rich Pin validation — the one-time gate

Once one `/r/{slug}/` page exists and is live on momrise.app:

1. Go to https://developers.pinterest.com/tools/url-debugger/
2. Paste the URL
3. Pinterest validates the schema
4. Click "Apply now"
5. Pinterest reviews (usually 1-2 business days)
6. Once approved, ALL future `/r/*` pages on momrise.app are Rich Pins
   automatically — no per-page work

This step is gating. Without it, all our pages render as standard pins
even with valid schema. Don't skip it.

---

## 7. Build estimate

| Task | Estimate | Notes |
|---|---|---|
| Recipe page renderer script | 4-5 hours | Read Firestore → render HTML → write to /r/{slug}/index.html |
| Stylesheet + page chrome | 2 hours | Keep it lean; mobile-first |
| Pin generator admin tool | 2-3 hours | List recipes, publish toggle, URL copy |
| Rich Pin validation | 30 min + 1-2 day wait | Submit + Pinterest review |
| Firestore field + rules update | 30 min | Trivial |
| **Total** | **~9-11 hours** | One focused session + a half-day for validation wait |

Phase 1.5 (defer): wire `generate-recipe-pages.js` into Codemagic's build
so it runs on every push, regenerating any recipe pages where the source
recipe changed since last build.

Phase 2 (defer): full creator-dashboard "Pinterest Studio" tab where
creators publish their own attributed recipes; HTML-to-image automation
for pin images.

---

## 8. Open questions before build

1. **Domain canonicalization**: should pins use `momrise.app/r/{slug}` or
   `momrise.app/recipes/{slug}`? Short = better. `/r/` it is unless you
   want to keep `/r/` reserved for the existing share-link pattern.
2. **Attribution**: when a recipe came from a creator code, do we show
   "Recipe by @{creator}" on the page? Yes, because it helps the creator
   AND it's accurate. But it also means the creator gets exposed in
   Pinterest scraping — fine as long as they consented to the program.
3. **What recipes count as "published"?**: my recommendation is
   admin-curated for Phase 1 (just Haley + Collin pick the first ~100).
   Phase 2 opens to creators. Phase 3 might open to all users with
   moderation.
4. **Caching**: GitHub Pages doesn't honor `Cache-Control` headers we'd
   want for stale-while-revalidate. Acceptable for Phase 1 because pages
   update infrequently.
5. **SEO impact on Google**: this is a free bonus — schema-marked recipe
   pages also rank in Google search. Don't optimize for it explicitly,
   but it might be the biggest install channel six months in.
