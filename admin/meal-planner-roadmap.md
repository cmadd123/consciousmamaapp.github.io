# MomRise Meal Planner Roadmap

Running list of upgrades to close gaps with ReciMe + differentiate on mom-first wedges. Updated as scope decisions are made.

**North star:** be the best meal planner for moms with families. Not the best recipe inbox (ReciMe owns that). Not the best baby app (Solid Starts owns that). The best at family meal planning *for moms* — composer-driven, family-aware, budget-conscious, Instacart-ready.

---

## Tier 1 — Close the visible gaps with ReciMe

These are the items where MomRise currently loses head-to-head. Ship these and you neutralize ReciMe's only real advantages.

### 1.1 — Recipe import from Instagram, TikTok, and screenshots
**Status:** Not started. Currently URL-only (works for blogs with schema.org markup, ~80% of cooking sites).

**Effort:** 2-3 weeks

**Plan:**
- **Week 1:** iOS Share Extension + Android Intent receiver. User shares an IG/TikTok URL → MomRise opens to "Importing recipe..." → backend hits TikTok oEmbed (sanctioned, free) or IG public HTML/OG tags → existing LLM parser structures it → editable preview → save.
- **Week 2:** Screenshot OCR import polish. We already have OCR. Make "screenshot a Reel and share to MomRise" the headline marketing line — works for ANY platform (IG, TikTok, Pinterest, Threads, BlueSky) and is legally bulletproof (user did the capture).
- **Week 3 (optional):** Audio transcription fallback. When caption is thin, "transcribe the video?" button using GPT-4o-mini-transcribe ($0.003/60s). User opt-in to control cost.

**Cost stack per import:** <$0.01 all-in (TikTok oEmbed free, IG fetch free, LLM parse ~$0.0002).

**Why critical:** Every mom on TikTok in 2026 expects "paste link → recipe saved." If she Googles "save TikTok recipe app," ReciMe wins. Closes the only ReciMe gap that affects acquisition.

---

### 1.2 — Cooking-mode utility parity
**Status:** Partial. Have step-off check. Missing screen-stay-on, unit converter, recipe scaler.

**Effort:** 4-5 days total

**Plan:**
- **Screen-stay-on / wake lock** (1 day) — Flutter `wakelock_plus` package, single config line on cooking-mode screen
- **Unit converter** (1-2 days) — tsp/tbsp/mL, °F/°C, oz/g static conversion table + UI affordance
- **Recipe scaler** (1-2 days) — 2 servings → 6 servings ratio math on existing ingredient amounts

**Why critical:** ReciMe ships all three free in their basic tier. Table stakes in 2026.

---

### 1.3 — Read-recipe-aloud (mini voice feature, not full voice mode)
**Status:** Not started.

**Effort:** 1 day for "read aloud" button + ~1 week for Siri shortcut

**Plan:**
- iOS `AVSpeechSynthesizer` + Android `TextToSpeech` for "Read aloud" button on recipe detail screen
- App Intents shortcut: "Hey Siri, next step in MomRise" — discoverable via tooltip
- **Do NOT build:** full voice assistant, wake-word, always-listening. Data says it doesn't move the needle.

**Why:** Solves "I'm holding a baby and can't read the screen" without the cost of a real voice mode. ~5% of users will use it; it's a talking point + accessibility win.

---

## Tier 2 — Organization upgrades (close hidden gaps)

### 2.1 — User-named collections (cookbooks)
**Status:** Not started. MomRise has favorites + meal-type categorization but no user-named folders.

**Effort:** 3-5 days

**Plan:**
- New Firestore collection: `cookbooks/{userId}/{cookbookId}` with name, description, recipe refs
- UI: "+ New Cookbook" button in recipe library, drag-to-cookbook gesture, browse cookbooks tab
- Examples to suggest at onboarding: "Quick Weeknights," "Holidays," "Kid Favorites," "Freezer Meals"

**Why:** Highest-impact organization upgrade. Moms self-organize recipes their own way. ReciMe wins on this; closing it removes their biggest "organization" advantage.

---

### 2.2 — Search by cook time + ingredient
**Status:** Has name search presumably. Missing cook time + ingredient.

**Effort:** 3-5 days

**Plan:**
- Add `cook_time_minutes: int` field to `MealRecord` schema (default null for existing records, prompt on view)
- Filter UI: "Under 20 min" / "Under 30 min" / "Under 1 hour" chips
- Ingredient search: "Show recipes with chicken" — query Firestore where ingredients array-contains "chicken"

**Why:** "I have 20 minutes and chicken" is the second-most-common recipe query after "what should I make tonight." ReciMe has it; you should too.

---

### 2.3 — Recipe tags (later, optional)
**Status:** Not started. Lower priority than collections.

**Effort:** 3-5 days

**Plan:** Tags on recipes ("freezer-friendly", "kid-favorite", "high-protein"). Self-organized by user. Filter by tag in library.

**Why later:** Collections cover ~80% of the use case with less complexity. Add this once collections are validated as a behavior.

---

## Tier 3 — The mom-specific wedges (where MomRise wins, expand)

### 3.1 — Baby Mode v1 ⭐ (the differentiating moat)
**Status:** Not started. Real opening — no competitor combines family meal planning with baby/solids guidance.

**Effort:** 5-6 weeks total

**Plan:**
- **Week 1:** Baby profile (DOB → derives age-stage: 6/9/12/18mo). 1 day. Allergen filter on existing recipes. 2-3 days.
- **Weeks 1-3:** Ingredient annotation layer. Flat table mapping ~50 most-common ingredients in MomRise's library to `{age-stage → cut/serve guidance, choking-risk, allergen}`. Seeded from AAP/CDC + cited. **This is where the cost is — RD review pass essential.**
- **Weeks 2-4:** "Baby view" on recipe cards. Collapsible panel showing baby-safe ingredients with cut/serve, ingredients to omit (salt, honey, raw sauce), summary plate. 1-2 weeks dev.
- **Week 4:** Lightweight allergen log. Tap food, mark introduced, optional reaction note. Skip dashboards.
- **Week 5:** Grocery list integration (baby's mods auto-flag the list: "buy plain unsalted broth for baby's portion"). AAP citations + disclaimers everywhere.
- **Week 5-6:** RD review pass + revisions.

**Phased launch:**
- v1: 50 ingredients RD-reviewed (the ones Haley's baby actually eats)
- v1.1: +25 ingredients (~1 month later)
- v1.2: +25 ingredients (~2 months later)
- Continue until ~200 covered

**Out of scope for v1:**
- Photos/videos of every food (Solid Starts' moat — don't compete on content depth)
- Separate "baby's plate" auto-meal-plan
- First-100-foods gamification
- Milestone tracking

**RD reviewer plan:**
- Email Edwena Kennedy (@mylittleeater), Rachel Rothman (Nutrition in Bloom), Yaffi Lvova, Marina Chaparro, Dani Lebovitz
- Budget: $2.5K-$5K for 50-ingredient initial review pass
- Get "Reviewed by [Name], RDN" attribution on every Baby Mode screen

**Why critical:** This is the wedge nobody owns. Solid Starts dominates standalone BLW. Family meal planners ignore babies. The middle (family planner WITH baby guidance integrated into the family recipe) is wide open.

---

### 3.2 — Per-kid preferences (picky-eater logic)
**Status:** Not started.

**Effort:** 2-3 weeks

**Plan:**
- Extend child profile model with `dislikes: List<String>`, `allergens: List<String>`, `picky_level: enum`
- Recipe view shows per-kid compatibility ("Liam loves this; Emma will need broccoli swapped")
- Meal plan view shows "everyone in the family is happy" indicator
- Swap suggestions on the fly ("kid won't eat onions → suggest carrots")

**Why:** ReciMe has zero family/kid logic. Every mom with 2+ kids needs this. Strong defensible wedge.

---

### 3.3 — Per-kid plate customization (Build-a-Plate)
**Status:** You have meal_combo_record (the schema is there). UX may need polish.

**Effort:** 1-2 weeks (UI primarily)

**Plan:**
- At plan time: "Tuesday dinner = chicken stir-fry. Liam's plate: chicken + rice (no sauce). Emma's plate: full version. Baby (9mo): shredded chicken + broccoli halved."
- Auto-derive baby's plate from Baby Mode annotations
- Manual overrides per kid

**Why:** HelloFresh has Build-a-Plate at the meal-kit level. No app has it at the meal-plan level. Combined with Baby Mode, this is the killer family feature.

---

## Tier 4 — Category-winning, longer-term

### 4.1 — Family multi-user with roles ⭐⭐
**Status:** Not started. Neither MomRise nor ReciMe has this. Whoever ships first wins the household stickiness war.

**Effort:** 6-8 weeks (real architecture work)

**Plan:**
- Multi-user accounts under one family (Mom = admin, Dad = editor, Grandma = viewer)
- Real-time sync of grocery list (Mom adds at home, Dad checks off in-store)
- Recipe attribution ("Dad cooked this Tuesday")
- Notifications: "Sarah added to grocery list"

**Why critical (long-term):** This is the category-winning move. Both apps are single-account. First to ship real family multi-user wins household stickiness for the next 5 years.

---

### 4.2 — Web companion
**Status:** Mobile-only. ReciMe has web for library viewing.

**Effort:** 4-6 weeks for a real web app

**Plan:**
- Read-only web view first (browse recipes, see grocery list, view plan)
- Edit support second (plan a week from your laptop)
- Mirror existing Firestore architecture; Next.js or Flutter Web

**Why:** Moms plan at the kitchen table on laptop. Mobile-only is a real gap.

**Lower priority** than family multi-user, but a natural extension once multi-user ships.

---

### 4.3 — Snack + side slots in meal plan
**Status:** 3-slot (B/L/D). Real mom day is 5-7 eating events.

**Effort:** 1-2 weeks (mostly UI)

**Plan:**
- Add "snacks" and "sides" categories
- Quick-add chips for common snacks
- Visual differentiation from main meals

**Why:** Real mom feeding day includes snacks. Both MomRise and ReciMe ignore this. First mover advantage.

---

### 4.4 — Pantry / inventory awareness
**Status:** Not started.

**Effort:** 3-4 weeks

**Plan:**
- "What I have" pantry tracker
- "What can I make from this" suggestions
- Avoid duplicate grocery items (don't buy chicken if you have 2 lbs in the fridge)

**Why:** Nori has a primitive version of this. Future differentiator, especially when food waste / inflation is on moms' minds.

---

## Tier 5 — Pre-launch / launch polish (not features)

### 5.1 — App Store screenshots (designer-produced)
**Status:** Current screenshots are decent but raw-ish.

**Effort:** Designer half-day, $300-500

**Plan:** Per the designer brief at `admin/aso-preview.html`. Lingualeo-style top-stacked + brand-gradient + UI inset. Test slot 1 via Apple PPO post-launch.

### 5.2 — Submit 2.2.4 to App Review
**Status:** 2.2.4 push is live (commit `69398053`). Codemagic should be building.

**Plan:** Once build lands in TestFlight, attach to App Store Connect submission, finalize App Privacy nutrition label, paste reviewer notes, click submit.

### 5.3 — Haley's name off the App Store
**Status:** Sticky.

**Plan:** File DBA in Alabama + Apple Trade Name request (`developer.apple.com/contact/topic/select` → Membership → Update Account Information).

### 5.4 — Play Store closed testing
**Status:** Pending. 14-day Google testing window required.

**Plan:** Recruit 5-7 real testers + 5-7 controlled accounts spread over days. Start now if June launch is real.

---

## Cross-cutting decisions to make

1. **Pricing for Baby Mode** — Keep inside existing subscription (recommended) or separate tier? Don't charge separately — invites Solid Starts comparison at $100/yr.

2. **RD partnership scope** — One-time review (~$5K) or ongoing advisor retainer ($1.5-3K/mo)? Recommendation: one-time first, evaluate ongoing.

3. **Family multi-user — Q2 or Q3?** This is the category-winning move. Earlier = bigger advantage. But it's real architecture work.

4. **Web companion priority** — Necessary for "best meal planner" claim, but mobile-first is fine for v1 launch. Q3 at earliest.

---

## Notes on what we're explicitly NOT building

- **Pinterest import** — strategically off-limits per creator strategy (DMCA, scraping legal risk)
- **Full voice assistant / wake-word** — data says it doesn't move the needle, Voicipe demonstrates the failure modes
- **Solid Starts-style content library** (videos of babies eating, full first-100-foods framework) — content arms race we won't win; differentiate on integration, not depth
- **Calendar/AI-agent territory** — Nori's lane, don't fight there
- **Browser extension** — wrong surface for mom audience
- **Pinterest-style recipe discovery feed** — separate product, scope creep

---

## Update log

- **2026-05-31** — Roadmap created. Tier 1 import + utilities most urgent. Tier 3.1 Baby Mode is the moat.
