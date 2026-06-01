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

### 4.5 — "Today's events" home card (in-app calendar banner)
**Status:** Not started. Complement to the 2.2.5 calendar push notifications — for moments when the mom has the app open and wants a glance-able view.

**Effort:** 2-3 days

**Plan:**
- New card on the home page (between Today's Meals and the rest of the day's content) that lists today's calendar events at a glance
- Displays event title + time, sorted chronologically, max ~3-5 lines (more behind a "show all" tap)
- Tappable card → routes into the Calendar tab
- Dismissible per-day via an X in the corner; resets at next midnight
- Hidden entirely if there are no events today (don't show an empty state — it's noise)

**Why:** Push notifications are good for when the app is closed (8 AM brief + 15-min before). When she's already in the app, a quiet always-there card is better than an interrupting toast or modal. Matches the "warm, not yelling" brand voice — chosen over Option B (slide-in floating banner) and Option C (bottom-sheet on launch) because both feel more invasive for daily use.

**Out of scope for v1:**
- Per-event reminder rescheduling from the card
- Multi-day forecast ("Tomorrow:" section)
- Custom dismiss durations (just per-day for now)
- Per-child filtering on the card (filter lives in Calendar tab)

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

## Tier 6 — Grocery affiliate revenue stream (the second engine)

This is what makes $10K total MRR achievable at **~600-700 active subs** instead of ~3,200 (subscription-only). Three engines, not one. The strategy: route each user to the affiliate path that matches her real shopping habit, not force everyone through IC.

**Three-engine unit economics:**
| Engine | Rate | Attribution | Status |
|---|---|---|---|
| Instacart | 5% on full cart | 7-day | **Live** (URL pattern), Impact contract signed |
| Walmart Affiliate | 1% on grocery | 3-day | Code exists (`walmart_api_service.dart`), not surfaced |
| Amazon Associates | 1% on grocery + **$3/Prime trial signup** | 24-hour, cart-wide | Not built |

**Blended per-active-sub: ~$12-14/mo affiliate revenue** (see 6.7 for the math). The Prime bounty is the strongest per-event revenue we have — $3/signup ≈ $300 of grocery commission equivalent.

**What we are NOT doing:**
- **Northfork middleware** — pricing estimated at $25K-$50K/yr minimum (their customer list is all enterprise: Walmart, Kroger, Tasty/BuzzFeed). At 1% Walmart commission, we'd need $200K-$400K/mo attributed GMV just to break even on the fee. Math doesn't work for our scale.
- **Spoonacular middleware** ($29-149/mo) — unnecessary since each retailer has a native affiliate path.
- **Walmart Commerce API** — enterprise approval, slow, uncertain. Not pursuing.

---

### 6.1 — Instacart (primary engine, 5%)
**Status:** Live via URL pattern. `instacart_affiliate_service.dart` builds search-param URLs against an Impact-tagged base URL in Remote Config. User taps "Shop using Instacart" → Instacart's site renders a pre-filled shopping list view → one-tap add-to-cart → checkout. Attribution validated with Lila Santos (Mar 2026).

**Optional upgrade — full Shoppable Recipes API (2-3 weeks):**
- Replace URL pattern with backend POST to IDP Shoppable Recipes endpoint
- Gains: better SKU match accuracy (quantity, unit, brand preference), per-recipe analytics, stable shopping list IDs
- Costs: 2-3 weeks engineering, requires Cloud Function infrastructure
- **Gate on real data:** if match accuracy is hurting conversion in first 4 weeks (check by tapping the button and inspecting Instacart's matches against the original recipe), do the upgrade. If matches look reasonable, defer indefinitely.

**Surface CTAs everywhere (7-day attribution requires saturation):**
- "Order ingredients" on every recipe view, not just grocery list page
- Inside cooking-mode footer (anticipates "I'm out of X")
- Weekly meal-plan summary card

---

### 6.2 — Walmart (secondary engine, 1%)
**Status:** `walmart_api_service.dart` exists (188 lines) using Walmart Affiliate API directly. Currently not prominently surfaced — the IC button dominates the UX.

**Effort:** 3-5 days to add a "Shop at Walmart" CTA with preference-aware routing (see 6.4).

**Plan:**
- Walmart Affiliate API returns product search URLs tagged with our affiliate ID → user lands on Walmart, manually adds each item to cart (higher friction than IC, but it works)
- Surface "Shop at Walmart" button for users whose `preferred_retailer` is Walmart
- Keep IC button as secondary option even for Walmart-primary users (some will use IC for convenience orders)
- 3-day attribution window — shorter than IC's 7-day, so CTAs still need to be near the purchase decision

**Why DIY, not Northfork:** Northfork's middleware (which would give IC-style pre-filled carts at Walmart) is out of budget by ~10x. Existing affiliate-link code earns the same 1% commission at zero ongoing cost. Lower-quality UX, but it serves the cohort we'd otherwise leave on the table.

---

### 6.3 — Amazon (tertiary engine — Prime bounty + specialty)
**Status:** Not built. Amazon Associates account assumed available (standard Amazon affiliate signup, no approval gate).

**Effort:** 1 week for affiliate links + Prime trial CTA flow.

**Plan:**
- **Prime bounty (~$3 per Prime free-trial signup):** The actual prize. Gentle CTA on Whole Foods / Amazon Fresh recipe paths — "Try Prime free, get Whole Foods delivery free for 30 days." Best per-event affiliate revenue available to us.
- **Specialty item affiliate links:** Spices, ethnic ingredients, specific brands the recipe calls for that Walmart/IC don't reliably stock. 1% commission, but Amazon is often the only natural source.
- **Equipment / one-time purchases:** Stockpot, slow cooker, baby food maker, cookbook. Some kitchen categories pay 3-4%.
- **24-hour cookie window** — short. But **cart-wide attribution within that 24h** is the saving grace — anything user adds to cart within the window earns us, not just the linked product.

**Why NOT primary cart:** 1% rate same as Walmart but with shorter cookie. Doesn't beat IC's 5%/7-day. Complement, not engine.

**What we are NOT doing:** Treating Amazon Fresh as a primary grocery cart. Alcohol affiliate (0% — Amazon excludes it).

---

### 6.4 — User preference detection in onboarding (the routing layer)
**Status:** Not started. The layer that makes the three-engine strategy actually work.

**Effort:** 3-5 days

**Plan:**
- Add one onboarding question: "Where do you usually grocery shop?" Options: Aldi, Publix, Kroger, Costco, Walmart, Target, Whole Foods, Other
- Store as `preferred_retailer` on user profile
- Route recipe-cart CTAs by retailer:
  - **IC-compatible answer** (Aldi, Publix, Kroger, Costco, Whole Foods, Sprouts) → IC button prominent
  - **Walmart answer** → Walmart button prominent, IC button secondary (still offered for convenience orders)
  - **Target answer** → Target affiliate (if/when we add it), IC fallback
  - **Other / no preference** → IC as default
- Show ALL options in a "more shopping options" expand — don't lock users into one path
- Allow change in settings later

**Why this matters:** Sending Walmart-primary moms to IC's higher prices burns trust and won't convert. Hiding the IC button from IC-compatible users loses revenue. Detect the habit, match the path.

**Expected impact:** Per-click conversion rate goes up materially (less bounce from "this isn't where I shop"). Blended affiliate revenue per active sub climbs from theoretical single-engine $6-7/mo to multi-engine $12-14/mo.

---

### 6.5 — Per-cohort attribution dashboard (internal)
**Status:** Not started. Critical for negotiation in 6.6 and for measuring whether the 6.4 routing layer is actually improving conversion.

**Effort:** 1-2 weeks

**Plan:**
- Instrument every cart open (IC, Walmart, Amazon) with `user_id`, `retailer`, `recipe_id`, timestamp, `preferred_retailer` (for routing accuracy measurement), `cart_value` (when reported back), order_status (new vs returning customer where available)
- Internal admin view (`admin/grocery-attribution.html`) showing:
  - Monthly attributed GMV split by retailer
  - Conversion rate per retailer (click → order)
  - Routing accuracy: % of clicks where chosen retailer matches preferred_retailer (sanity check on 6.4)
  - AOV per cohort (recipe-led carts should beat IC's ~$95 site-wide avg)
  - New-to-Instacart customer rate (critical IC metric — they pay extra for these)
  - Repeat-cart rate at 30/60/90 days
  - Prime bounty conversions
  - IC+ membership conversion rate (separate revenue line)
- Tag each recipe with cuisine, prep time, cost-tier → figure out which recipe types drive the highest-value carts

**Why:** When we ask Lila for a rate increase at month 4-6, this is the data she'll want. And before then, we need it to know if the 6.4 routing layer is doing what we expect.

---

### 6.6 — Instacart commission rate negotiation (relationship, not engineering)
**Status:** Confirmed via signed Impact.com contract: **5% flat on Order Placed, 5% flat on New User Activation, 7-day attribution, no CPA bonus.** Partner manager is Lila Santos (developers@instacart.com).

**Effort:** Quarterly check-ins, not a sprint

**Plan:**
- **Months 1-3 post-launch:** Ship integration, instrument cohort dashboard, do NOT ask for a rate increase. Build a track record. Keep Lila in the loop on milestones (first 100 orders, first $1K GMV, etc.) — relationship maintenance, not asking.
- **Month ~4** (or when monthly attributed GMV hits a meaningful threshold): First negotiation ask. Bring:
  - New-to-IC customer rate (likely above their site avg — moms are stickier converters)
  - Monthly attributed GMV trend
  - AOV proof (recipe-led carts > IC site avg of ~$95)
  - Repeat-order rate at 30/60/90 days
- **Realistic stretch ceiling for IDP partners:** ~7-10% revshare. The widely-quoted "up to 15%" rate is the **Influencer/Creator track** — a different Instacart program with different terms, not available to IDP integrators. No published case study shows an IDP app cracking 5%, so anything above is best-effort estimation.
- **Months 8-12:** Leverage point — credible threat of integrating a competitor (Shipt, Kroger, etc.) makes IC defensive about losing the volume. Don't bluff; have the integration scoped before asking.

**Confirmed:** Rate changes are 1:1 negotiated via Impact contract amendment. No published tier table. No first-person disclosures from any IDP partner of a successful rate increase — we'd be in early territory if it works.

**Open question:** Whether a CPA bonus on new-to-IC orders is negotiable separately from revshare. The standard Affiliate/Publisher track ships with $10 CPA but IDP does not. Adding CPA may be an easier first ask than raising revshare.

---

### 6.7 — Real grocery cart data + three-engine revenue model
**Why this section exists:** Earlier modeling assumed $90/week carts AND treated Instacart as the only revenue engine. Both were wrong. USDA Food Plans data corrects cart size; the three-engine model (6.1-6.4) corrects per-sub revenue upward.

**USDA Food Plans (Jan 2026, monthly cost per family):**
| Family size | Thrifty | Low-Cost | Moderate | Liberal |
|---|---|---|---|---|
| 3-4 ppl | $230-275/wk | $290-340/wk | $360-420/wk | $440-525/wk |
| 5-6 ppl | $310-375/wk | $390-465/wk | $480-560/wk | $590-700/wk |

**Haley (target archetype, family of 6):** $1,000+/mo confirmed → ~$230/wk → sitting in the **Thrifty** band. Disciplined shopper using Aldi + Publix, not the average.

**Three-engine revenue model:**
- Average MomRise mom (family of 4-5, mixed stores): ~$300-400/wk = ~$1,300-1,700/mo grocery spend
- If 30-40% flows through affiliate paths, attributable monthly GMV per active sub = ~$400-600
- Retailer cohort split (corrected — Southeast/Aldi/Publix coverage is bigger than first estimated):
  - **IC-compatible (Aldi, Publix, Kroger, Costco, Whole Foods, etc.) — ~40-50% of base:** 5% × ~$500/mo attributed = **~$25/mo per sub**
  - **Walmart-primary — ~40-50% of base:** 1% × ~$400/mo attributed = **~$4/mo per sub**
  - **No affiliate path (Trader Joe's, Sprouts not on IC, local stores) — ~5-10%:** $0
- **Amazon (cross-cutting, not retailer-exclusive):**
  - Prime bounty ~$3 per signup. Assume 30% of subs sign up for Prime trial via our CTA over 6 months → averaged ~$1.50/sub/mo
  - Specialty item commissions ~1% on ~$50/mo cart × 40% conversion = ~$0.20/sub/mo
  - Combined Amazon contribution: ~$1.70/sub/mo
- **Blended across all active subs: ~$12-14/mo per active sub** in affiliate revenue
- **At ~600-700 active subs:** ~$8K affiliate alone, on top of subscription revenue, gets us to $10K total MRR

**Math sanity:** Earlier $6-7/mo estimate assumed single-engine (IC only) and underweighted IC-compatible cohort. Three-engine + corrected cohort split roughly doubles per-sub revenue.

---

### 6.8 — Pricing reframe (defer until launch data)
**Status:** Considered, deliberately deferred.

**Question:** Lower sub price + raise creator share so creator earns same $ at lower price tag, while affiliate revenue picks up the gap?

**Math sketch:**
- Current: $4.99/mo sub, creator earns ~$X
- Hypothetical: $2.99/mo sub, raised creator %, creator earns same $X, MomRise net is lower BUT volume goes up + affiliate per-sub revenue (~$12-14/mo blended in the three-engine model) starts to compete with the sub margin difference
- Break-even threshold: depends on real affiliate flow-through rate. More compelling now with the corrected $12-14/mo number than at the earlier single-engine $6-7/mo estimate, but still gated on real measured data.

**Why we're NOT doing this yet:**
1. Lowering sub price is permanent (raising it later = churn)
2. We have zero real conversion data at $4.99 yet — could be converting fine
3. Affiliate per-sub revenue is modeled, not measured — need 3 months of post-launch data to know the true number
4. Creator program value prop ("earn $X/sub") gets harder to message if % keeps moving

**When to revisit:** Month 4-6 post-launch, after we have real conversion-rate-at-$4.99 + real affiliate-per-sub data from the three-engine model.

---

### 6.9 — Open action items (launch week)

- [ ] **Connect bank account to Impact.com** for IC affiliate payouts (separate from Stripe Connect — Impact handles affiliate payouts independently)
- [ ] **Verify Impact dashboard** is tracking clicks and orders since launch this week. 7-day attribution means first signal lands ~2 weeks post-launch; if zero clicks at week 1, attribution may be misconfigured
- [ ] **Inspect IC match quality** — tap "Shop using Instacart" on 5-10 real recipes, check whether ingredients map to reasonable products. If matches look bad, prioritize 6.1's optional Shoppable Recipes API upgrade
- [ ] **Verify `walmart_api_service.dart` still works** post-Apple-launch — last touched months ago, may need a smoke test before 6.2 surfacing

---

## Update log

- **2026-05-31** — Roadmap created. Tier 1 import + utilities most urgent. Tier 3.1 Baby Mode is the moat.
- **2026-06-01** — Added Tier 6 (grocery affiliate revenue stream). Walmart path corrected (Northfork middleware, 1% not 4%). IC commission negotiation playbook scoped. Real cart data from USDA + Haley's spend replaces earlier $90/wk under-estimate. Pricing reframe deferred to month 4-6 pending real launch data.
- **2026-06-01 (later)** — Confirmed IC rate via signed Impact.com contract: 5% flat on both Order Placed and New User Activation, 7-day attribution, no CPA bonus. Corrected negotiation ceiling from "8-12%" speculation to "~7-10% best-effort, no public IDP precedent." Corrected per-sub blended affiliate revenue from $10-15/mo down to ~$6-7/mo. Corrected $10K MRR target from ~770 subs to ~1,100-1,200 subs. Added 6.7 open action items (Impact bank connection, re-ping Lila, verify Impact dashboard).
- **2026-06-01 (Tier 6 rewrite to three-engine model)** — Northfork dropped (pricing ~$25K-$50K/yr, math doesn't work at our scale). Spoonacular dropped (unnecessary middleware). New structure: 6.1 IC primary (URL pattern already shipped, full API as optional upgrade gated on real match-quality data), 6.2 Walmart secondary via existing `walmart_api_service.dart` (no Northfork), 6.3 Amazon tertiary (Prime $3 bounty + specialty items), 6.4 user preference detection in onboarding (the routing layer). Corrected cohort split — IC-compatible cohort is ~40-50% of base (was estimated 15%) since Aldi/Publix/Kroger/Costco are all on IC. Three-engine blended revenue: ~$12-14/mo per active sub. Updated $10K MRR target to ~600-700 active subs.
- **2026-06-01 (Tier 4.5 added)** — In-app "Today's events" home card queued for 2.3.0. Complement to the calendar push notifications shipped in 2.2.5. Chose always-visible dismissible card over slide-in toast (too invasive on cooking-mode) and bottom-sheet on launch (gets annoying after a week).
