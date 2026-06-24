# MomRise Session Recap — May 31, 2026

Comprehensive record of decisions, research, and actionable conclusions from today's working session. Designed to be picked up by future-you (or anyone else) without context loss.

---

## TL;DR — the 5 most important calls

1. **Apple Small Business Program enrolled** → 15% commission (was 30%). 15-day-of-fiscal-month-end activation: in effect from ~June 15.
2. **Don't ship the welcome creator-code bottom sheet** to users yet. 2.2.4 build has it commented out (commit `69398053`).
3. **Close the import gap with ReciMe** (IG/TikTok/screenshot recipe import) as the single highest-leverage feature investment. 2-3 weeks of work.
4. **Baby Mode (RD-reviewed) is the moat nobody owns.** 5-6 week project. Email Edwena Kennedy / Rachel Rothman / Yaffi Lvova for RD review.
5. **Don't merge phase2-fresh into main yet.** Ship current main first. Phase2 work is a second-wave migration after this version is approved.

---

## What we shipped today (code/content)

### Server / functions
- ✅ **Apple webhook env-mismatch fix** (verified end-to-end working)
- ✅ **Apple price-lookup product table** + milliunit conversion fix
- ✅ **Per-creator rev share** (Apple + Stripe)
- ✅ **Sandbox isolation** across all earning surfaces
- ✅ **Earning-landed email** (notifyOnCreatorEarning)
- ✅ **Payout-sent email** (notifyOnCreatorPayout)
- ✅ **Admin: edit creator rev share from dashboard**
- ✅ **Stripe Connect platform integration** code reset for STONE45

### Web pages
- ✅ **Updated privacy policy** with subscription, attribution, creator-program disclosures (`privacy.html`)
- ✅ **Updated Terms of Service** with Section 7a (Health/Nutrition/Baby-Feeding Content), beefed-up Section 9 (Limitation of Liability), new Section 9a (Indemnification) — `terms.html`
- ✅ **Creator playbook** at `/creator/playbook/` — mom-friendly voice, 3-week sample schedule, caption templates
- ✅ **Creator brand kit** at `/creator/brand-kit/` — logo, palette, fonts, do/don't, downloads
- ✅ **Creator agreement v1** at `/creator/agreement.html` + required checkbox on apply form
- ✅ **App Store screenshot mockup** at `/admin/aso-preview.html` (direction for designer)
- ✅ **Schema.org markup + Open Graph** on homepage for LLM/SEO discovery

### App (iOS)
- ✅ **2.2.4 build pushed** (`pubspec: 2.2.4+522`, commit `69398053`)
- ✅ Welcome creator-code bottom sheet commented out in both `paiment_copy_widget.dart` and `welcome_celebration_widget.dart`
- ✅ "Got a creator code?" paywall link stays
- ✅ "Add Creator Code" Settings tile stays
- ✅ Cancel Subscription → Apple deep link
- ✅ Paywall snackbar fix (no false "confirming" on cancel)
- ✅ Apple IAP `appAccountToken` (server-side, invisible)
- ✅ Deferred attribution claim on login (server-side, silent)

### Admin docs (planning)
- ✅ `admin/meal-planner-roadmap.md` — 5-tier upgrade list (this is the running living doc)
- ✅ `admin/baby-mode-disclaimers.md` — in-app disclaimer copy + implementation checklist
- ✅ `admin/app-review-notes.md` — paste-ready reviewer notes block for App Store Connect
- ✅ `admin/aso-preview.html` — App Store screenshot direction mockup
- ✅ `admin/session-recap-may-31-2026.md` — this file
- ✅ `admin/seed-test-creator.js`, `admin/test_clawback.js`, `admin/cleanup_test_data.js` — admin scripts

---

## Key decisions

### On the creator program
- **Phase 2 strategy (web/app):** ship without forcing creator surfaces on users until real creators are onboarded. Welcome bottom sheet pulled.
- **Rev share:** Per-creator override (currently STONE45 at 40%); default 50% if unset; stored on every earning row for audit + refund parity.
- **Creator agreement:** v1 live, click-wrap on apply form with version tracking.
- **First creator recruitment:** Hand-pick 3-5 micro creators (1-10k followers); don't open /apply/ widely yet.

### On competitive positioning
- **Don't compete with ReciMe on recipe organization** — they're 3 years and $2M ahead.
- **Don't compete with Solid Starts on baby content depth** — they have feeding therapists in-house.
- **Don't compete with Nori on calendar/AI agent** — capital-intensive race with ex-ByteDance team.
- **DO own:** mom-first family meal planning with Baby Mode integration. Mom-as-protagonist (not baby-centered or family-neutral).

### On meal planner roadmap (see full doc)
- **Tier 1 (close gaps):** IG/TikTok import (2-3 wk), cooking utilities (4-5 days), read-aloud (1 day)
- **Tier 2 (organization):** user-named collections (3-5 days), search by cook time + ingredient (3-5 days)
- **Tier 3 (mom wedge):** Baby Mode v1 (5-6 wk), per-kid preferences, plate customization
- **Tier 4 (category-winning):** family multi-user, web companion, snack/side slots, pantry
- **Tier 5 (launch polish):** screenshots, submit 2.2.4, Haley's name change, Play Store testing

### On screenshots
- Current live screenshots are decent (enough for approval).
- Need designer for polished set ($300-500, half-day) → Lingualeo-style reference.
- A/B test slot 1 via Apple PPO post-launch.
- **App Store listing screenshots = same files Apple uses for search-result thumbnails** (Apple auto-crops). One upload set.

### On subtitle
- Current: "Milestones, routines, calendar" → weak, no differentiator
- Recommended: **"Meal planner + mom-life HQ"** (26 chars, fits Apple's 30-char limit, follows winning category-keyword + differentiator pattern)

### On Apple developer name (Haley)
- Currently shows "Haley Maddox" as seller + artist + (if set) copyright
- **Path A (recommended):** File AL DBA (~$35 at county probate) + Apple Trade Name request via developer.apple.com/contact → Membership → Update Account Information. 2-3 week turnaround.
- **Path B (longer-term):** Form MomRise LLC, upgrade to Organization account, transfer app. $300-500 + 2-4 weeks.

### On Apple Small Business Program
- ✅ Enrolled today.
- Effective from 15 days after the fiscal month-end (likely ~June 15).
- Changes commission from 30% → 15%. Doubles MomRise's net per sub.

### On Baby Mode
- **Scope:** 50 ingredients in v1 (most common foods Haley's actual baby eats), expand monthly to 200.
- **RD review:** Email Edwena Kennedy (@mylittleeater) first; backup options Rachel Rothman, Yaffi Lvova, Marina Chaparro, Dani Lebovitz.
- **Budget:** $2,500-$5,000 for 50-ingredient one-time review pass.
- **Timeline if started this week:** ~10-13 weeks from first email to launch with "Reviewed by [Name], RDN" attribution.
- **Legal protection without RD:** strong disclaimers in ToS (Section 7a — already added) + AAP/CDC citations on every guideline + business insurance ($500-$1000/yr).
- **Phased launch as marketing moments:** "Baby Mode now covers 75 foods" / "100 foods" / etc.

### On Play Store
- **Tester rules:** Google requires 12+ testers opted in for 14 days before production. Technically can use multiple controlled emails but spirit of rule is real testers.
- **Realistic approach:** 5-7 real testers (family/friends/first creators) + 5-7 controlled accounts, spread opt-ins over days, diverse devices.
- **Start NOW** if June launch is real — 14-day clock is the long pole.

### On voice/hands-free features
- **Skip the full voice mode.** 5% adoption per research; Voicipe/Yummly demonstrate it doesn't move the needle.
- **DO ship the cheap version:** "Read recipe aloud" button (1 day, `AVSpeechSynthesizer`) + App Intents shortcut "Hey Siri, next step in MomRise" (1 week).
- **Don't:** wake-word, always-listening, custom voice assistant.

---

## Active blockers + ownership

| Blocker | Owner | Path |
|---|---|---|
| Stripe Connect platform signup + ID docs | Haley | In progress (or done if she's completed it) |
| Stripe webhook URL configured in Stripe dashboard | Collin/Haley | After Connect is live: Stripe → Developers → Webhooks → `https://us-central1-parenting-plus-7szrif.cloudfunctions.net/stripeWebhook` (subscribe: account.updated, invoice.payment_succeeded, charge.refunded) — both test + live modes separately |
| MomRise 2.x submitted to App Review | Collin | Path documented in `admin/app-review-notes.md` — needs Build 2.2.4 attached, privacy nutrition label updated, reviewer notes pasted |
| App Store screenshots designed | Designer | Brief documented in this session; budget $300-500 for half-day work |
| Haley's name removed from App Store | Haley | DBA + Apple Trade Name request |
| Play Store 14-day testing window | Collin | Start NOW if June launch is target |
| RD identified for Baby Mode | Collin | Email Edwena Kennedy first |

---

## Strategic claims (with confidence levels)

| Claim | Confidence |
|---|---|
| MomRise can credibly be "best meal planner for moms with families" after closing import gap + cooking utilities | **High** |
| MomRise can credibly be "best recipe organizer" | **Low** — ReciMe owns this, don't fight |
| Baby Mode is a wedge no competitor owns | **High** — verified across competitive research |
| Family multi-user is the category-winning long-term move | **High** — neither MomRise nor ReciMe has it; whoever ships first wins |
| Closing IG/TikTok import gap is the highest-leverage feature investment | **High** — every mom on TikTok in 2026 expects "paste link → recipe" |
| Voice/hands-free is shiny-object territory at full-build scale | **High** — 5% adoption, Voicipe failure modes |
| App Store screenshots can be swapped post-launch without resubmission | **High** — Apple PPO supports this |
| Apple App Review will approve 2.2.4 without flagging creator-code features | **Medium** — reviewer notes pre-empt the most likely confusion, but App Review is unpredictable |
| RD-reviewed Baby Mode dramatically out-positions un-reviewed competitors | **High** — Solid Starts plays this pattern exclusively |
| The "10× UGC vs polished content" stat applies to social media, NOT App Store screenshots | **High** — I conflated these earlier; corrected |

---

## Outstanding strategic questions (deferred)

These came up but weren't fully resolved today:

1. **Pricing for Baby Mode** — keep inside existing subscription (recommended) or charge separately? Leaning included; don't invite Solid Starts $100/yr comparison.
2. **Family multi-user — Q2 or Q3 build?** Real architecture work, but it's the category-winning move. Trade-off between earlier shipping vs. shipping with other Tier 1/2 polish.
3. **Tags on recipes — ship in Tier 2 or skip?** Collections cover ~80% of the use case. Defer tags unless validated demand.
4. **Web companion priority** — necessary for "best meal planner" claim, but mobile-first is fine for v1. Q3 at earliest.
5. **Pinterest content strategy** for organic traffic — long-term play, requires real content investment (recipe pages, milestone guides). Q3+ priority.

---

## Files created today (paths)

```
admin/
├── aso-preview.html              # Screenshot design mockup for designer reference
├── app-review-notes.md           # Paste-ready App Store reviewer notes
├── baby-mode-disclaimers.md      # In-app disclaimer copy for Baby Mode
├── meal-planner-roadmap.md       # Running 5-tier upgrade list
├── seed-test-creator.js          # One-shot creator seeder
├── test_clawback.js              # Local refund simulator
├── cleanup_test_data.js          # Wipe sandbox test artifacts
└── session-recap-may-31-2026.md  # This file

creator/
├── brand-kit/index.html          # Logo, colors, fonts, voice
├── playbook/index.html           # Mom-friendly creator playbook
└── agreement.html                # Creator agreement v1

functions/
├── creator_notifications.js      # Earning + payout emails
└── (apple_iap_functions.js, stripe_functions.js, creator_attribution_match.js etc. all updated)

terms.html                         # Updated: Section 7a, beefed-up Section 9, new Section 9a
privacy.html                       # Updated: subscription, attribution, creator-program disclosures
index.html                         # Schema.org markup + Open Graph
```

---

## Sources used in today's research

Compiled from agent research sessions today, for future reference:

**Creator/influencer marketing:**
- Influencer Marketing Hub Benchmark Report 2026
- HypeAuditor Instagram Engagement Rate 2025 (76M accounts)
- Metricool x HypeAuditor 2025 Instagram Content Playbook
- Emplifi Q3 2025 (UGC vs polished, the 10× stat)
- Tandfonline 2024 (frequency of sponsored posts)
- FTC Blurred Lines staff report (eye-tracking on disclosure)

**Competitive (apps):**
- ReciMe iOS/Play Store listings + ReciMe help docs
- Nori Family AI launch coverage (Domus Next, Marissa Mayer, June hardware)
- The Mom App (iOS + Play, TJ Walton Digital Marketing)
- Solid Starts app + competitive teardowns
- Plan to Eat, Mealime, PlateJoy reviews
- Headspace, Calm, Peanut, Huckleberry, BabyCenter, What to Expect listings

**App Store / ASO:**
- Storemaven / Phiture eye-tracking studies
- AppTweak ASO blog (screenshot optimization, App Store vs Ad creative)
- SplitMetrics case studies (Prisma, Hobnob, textPlus, Empire City Casino)
- ScreenFast 2026 conversion benchmarks
- Gummicube portrait vs landscape

**Legal / RD review:**
- Academy of Nutrition and Dietetics directory
- PNPG (Pediatric Nutrition Practice Group)
- AAP / HealthyChildren.org choking guidance
- CDC infant nutrition guidance
- Dietitian liability insurance scope (Well Resourced Dietitian)

**Apple / Google:**
- Apple Small Business Program documentation
- App Store Connect submission flow
- Apple's developer name change / DBA process
- Google Play closed testing requirements

---

## What to do Monday morning (suggested order)

1. **Verify 2.2.4 build landed in TestFlight** (App Store Connect → TestFlight → iOS Builds → look for 2.2.4)
2. **Attach 2.2.4 build to App Store Connect submission**
3. **Update App Privacy nutrition label** in App Store Connect to match the live privacy policy (table in this session's earlier work)
4. **Paste reviewer notes** from `admin/app-review-notes.md` into App Store Connect → App Information → Notes for Review
5. **Submit 2.2.4 for Review**
6. **In parallel: email 3 designers** with the screenshot brief
7. **In parallel: email 3 RDs** from the Baby Mode list with the templated message
8. **Verify Haley has filed DBA + Apple support request**
9. **Start Play Store 14-day testing window** (recruit testers, push internal AAB)
10. **Begin cooking utilities work** (4-5 days, contained: wakelock + scaler + unit converter)

That's the priority queue. Everything else from the roadmap can wait until this batch is shipped.
