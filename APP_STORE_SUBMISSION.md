# MomRise App Store Submission Reference

Everything needed to fill out App Store Connect. Copy/paste from here.

## Metadata

### App Name — 30 chars
```
MomRise: Family Meal Planner
```

### Subtitle — 30 chars
```
Milestones, routines, calendar
```

### Keywords — 100 chars (no spaces between commas)
```
toddler,baby,parenting,children,grocery,recipe,chore,learning,development,growth,organize
```

### Promotional Text — 170 chars (editable without resubmission)
```
Stop staring at the fridge at 5pm. Start your 7-day free trial — plan meals, track milestones, and organize the whole crew in one warm app.
```

### Categories
- Primary: **Lifestyle**
- Secondary: **Health & Fitness**

### Age Rating
4+ (no objectionable content)

---

## Description — 4,000 char budget

```
MomRise is your mom-life command center: plan family meals in minutes, track every milestone, build AI learning paths, and organize the whole crew — warm, simple, and all in one.

Built for the mom who's tired of juggling three apps and a whiteboard.

━━ THE WEEKLY MEAL PLANNER YOU'LL ACTUALLY USE ━━

• Plan a full week of family meals in about five minutes
• Auto-generated grocery list, sent straight to Instacart
• A meal planner with recipes for picky eaters and busy weeks
• Save your favorites, import recipes from any website
• Breakfast, lunch, dinner, and snacks — color-coded per kid

━━ BABY & TODDLER MILESTONE TRACKER ━━

• Personalized milestones by age, from newborn through early school
• Physical, cognitive, social, and self-care categories
• "Is this normal?" — answered with a calm, research-backed reference
• Track multiple children in one place, without toggling profiles

━━ AI-POWERED PARENTING COACH ━━

• Tell MomRise what you're working on ("transition to big-kid bed")
• Get a personalized, age-appropriate plan with parent tips
• AI learning paths built for real life, not a parenting textbook
• Smart activity and routine suggestions based on your child's stage

━━ SHARED FAMILY CALENDAR ━━

• A shared family calendar for parents, sitters, and grandparents
• Playdates, pediatrician visits, half-days — everything in one view
• Color-coded per child, per adult
• Routines, to-dos, and calendar events side by side

━━ WHY MOMS LOVE MOMRISE ━━

• Warm and human, never clinical
• Works for the whole family — toddler, preschooler, early school
• Private by default; your data stays yours
• 7-day free trial, then $6.99/month or $69.99/year

Questions, feedback, or a feature request? We actually read them all: support@consciousmama.app
```

---

## In-App Purchase names (indexed for search)

| IAP | Display Name (≤30) | Description (≤45) |
|---|---|---|
| Monthly subscription | `MomRise Family Planner` | `Weekly meal planner, milestones & routines` |
| Yearly subscription | `MomRise Meal Planner Yearly` | `Full year of meal plans, milestones & AI tips` |

Update these in App Store Connect → In-App Purchases. Requires re-approval (24-48h).

---

## Screenshots

### Files to upload

Location: [`app_store_assets/ios_6.5_marketing/`](app_store_assets/ios_6.5_marketing/) (1284×2778, 6.5" display spec — auto-scales down)

If App Store Connect requests 6.7": [`app_store_assets/ios_6.7_marketing/`](app_store_assets/ios_6.7_marketing/) (1290×2796)

### Upload order (first 3 are what shows in search previews)

1. `02_events_todos_routines.png` — **hero** ("Mom life, simplified.")
2. `07_grocery_instacart.png` — unique feature ("Meals planned, ingredients delivered.")
3. `04_milestones.png` — emotional hook ("Every first, remembered.")
4. `01_home.png` — home context
5. `03_calendar.png` — calendar detail
6. `05_milestones_detail.png` — milestone depth
7. `06_new_event.png` — event creation

### Play Store (Android)
Not prepped yet. iOS screenshots would work but would look out of place. Flag when submitting the Play listing — we'll generate Android-native shots.

---

## URLs (required)

- **Privacy Policy URL**: `https://momrise.app/privacy.html`
- **Terms of Service URL**: `https://momrise.app/terms.html`
- **Support URL**: `https://momrise.app/support.html`
- **Marketing URL** (optional): `https://momrise.app/`
- **Become a Creator URL** (internal link, not required for App Store): `https://momrise.app/apply/`

---

## Submission sequencing checklist

- [ ] Build uploaded to TestFlight (Codemagic → iOS workflow pushes here on phase2-fresh → main merges)
- [ ] Test build with real Stripe test cards end-to-end
- [ ] Fill all metadata fields from this doc
- [ ] Upload 7 screenshots in the order above
- [ ] Set IAP names + descriptions (see above), submit IAPs for review
- [ ] Privacy questionnaire (App Store Connect → App Privacy) — make sure disclosures match what MomRise collects (email, child age/name, meal plans, milestones)
- [ ] Submit for review
- [ ] After approval: do NOT push a new build for at least 48 hours unless critical — let the version settle and accumulate review impressions

Typical review time: 24-48 hours (as of 2025).

---

## Post-launch ASO iteration loop

Month 1: track baseline. Do nothing to metadata. Focus on install velocity + reviews.

Month 2: read App Store Connect → Analytics → Acquisition → **Search**. Note:
- Which queries impressioned the most?
- Which queries converted impression → install best?
- Where you rank #10-20 on a query that converts well = candidate to phrase-optimize for.

Month 3+: swap one subtitle phrase to phrase-optimize the top-converting query. Measure for 30 days. If rank position improves AND conversion holds, keep it. If not, revert.

Promo text is updatable *between* reviews — rotate every 2-3 weeks for seasonal/novelty lift.

---

## Ranking algorithm weighting (rough 2025 consensus)

| Signal | Weight |
|---|---|
| Install velocity (weighted toward week-1) | ~40% |
| Retention + engagement + reviews | ~35% |
| Metadata (name, subtitle, keywords, description, screenshot captions) | ~25% |

**Reviews threshold** for Apple's algorithm to start trusting you: ~20 reviews at 4.5+ stars. Until then, you'll underperform on competitive terms regardless of metadata quality.

---

## Rate-me trigger (when built)

Use Apple's native `SKStoreReviewController` via the Flutter `in_app_review` package (capped to 3 prompts per user per 365 days by Apple).

Trigger from 2-3 positive moments only:
- After first meal plan saved
- On day 4 of trial
- After 10th app open with a qualifying positive action

Never trigger:
- Right after sign-up
- After an error or crash
- On app launch
- On the paywall

Not implemented yet. Belongs in phase2-fresh.

---

## Key resources

- [Apple Product Page metadata rules](https://developer.apple.com/app-store/product-page/)
- [AppFigures 2025 algorithm guide](https://appfigures.com/resources/guides/app-store-algorithm-update-2025)
- [AppRadar ASO guide](https://appradar.com/academy/apple-app-store-optimization-aso)
- [MobileAction keyword research guide](https://www.mobileaction.co/blog/aso-keyword-research/)

---

_Last updated: 2026-04-21_
