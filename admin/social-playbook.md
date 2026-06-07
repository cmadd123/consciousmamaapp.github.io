# MomRise Social Playbook

Last updated: 2026-06-03

What MomRise's owned channels (IG + Pinterest) post, what creators are asked to
post, and how the rev-share / VESEL67-style code program stays FTC-compliant.

**Scope reminder**: MomRise's IG and Pinterest are primarily run by Collin +
Haley. The audience is creators looking for a template to mimic and tag, NOT
end users. "Polished consumer brand" is the wrong target. "Real-mom-in-kitchen
that creators can copy" is the right one.

Built from two deep-research runs (2026-06-03). Where a claim came back
medium or low confidence I've called it out so it doesn't drift into
treated-as-fact territory.

---

## A. MomRise IG — operating model

### A1. Posting rhythm — weekly, not daily

**3-4 posts per week, all Collab-eligible.** Inferred from synthesis, not
directly cited. The reasoning:

- Collab requires a Reel, Feed post, or carousel — three formats, three
  natural slots.
- Anything more frequent than ~4/week pushes the account toward
  consumer-broadcast aesthetic, which conflicts with the creator-mimicry
  goal.
- Anything less frequent than 3/week starves creators of fresh Collab-eligible
  content to ride alongside.

Don't lock a strict day-of-week schedule. Aim for **Mon / Wed / Fri** as the
default cadence, with an optional Saturday creator-spotlight repost when
worth it.

### A2. Format mix — all "friend's food diary" aesthetic

All three formats below work because they're documented creator genres in
the food space (Chobani, HelloFresh examples). High confidence.

| Format | Frequency | Intent |
|---|---|---|
| **What I Feed My Kids This Week** (carousel) | 1/week | Multi-meal product integration. Each slide = one meal planned in the app. The whole carousel = one week's plan. Mimicry template for creators. |
| **Cook With Me** Reel (15-60s, founder Haley voiceover) | 1-2/week | POV cooking a single recipe imported from a creator. Casual, handheld, no studio lighting. Demonstrates the import + cook flow. |
| **Behind-the-scenes founder content** (Reel or carousel) | 1/week | "How we picked this week's recipes," "what changed in this build," "Collin testing the grocery list." Humanizes the brand, gives creators reasonable founder-tag material. |

**Do NOT post studio-polished hero shots, stock-photo carousels, or
infographic-style "5 tips" posts.** None of those translate into something a
micro-creator can mimic, and the brand-mimicry pattern is the whole point of
the account.

### A3. First 4 brand posts to publish

1. **"What I Feed My Toddler This Week"** carousel — 7 slides, one meal per
   slide, app screenshot of the planned week at the end. Caption: "This
   week's plan, all imported from TikTok in about 20 minutes. (Yes, Tuesday's
   nuggets are still here.)" Tag whatever creator originated each recipe.
2. **Cook With Me Reel** — Haley imports one TikTok recipe live in MomRise,
   makes it. 45 seconds, voiceover, no music swap, no captions on screen
   beyond "Recipe by @[creator]." Use a recipe from one of your active
   creators (VESEL67 if she has one) so they have a tag-able moment.
3. **Behind-the-scenes Reel** — "How we test recipe imports." Collin or Haley
   on phone, shows the share extension → recipe arrives → meal plan added.
   30 seconds. Quiet voiceover. Demonstrates the product in the most
   creator-mimic-able way possible.
4. **Creator spotlight repost** — Repost one of your active creators using
   their code, full credit, Collab them on the repost. Caption pattern:
   "Watching @[creator] use code VESEL67 in MomRise is exactly what we built
   this for. Save the recipe by tapping share." Sets the precedent that the
   brand actively boosts creators back.

### A4. Collab post mechanics — who hosts matters

| Mechanic | What's confirmed |
|---|---|
| Cap on accounts | 1 host + 5 invited = **6 total accounts per Collab**. High confidence (Instagram Help + 3 secondary sources). |
| Supported formats | **Feed posts, carousels, Reels.** Stories are NOT supported as co-authored Collabs. High confidence. |
| Eligibility | Both accounts must be **Business or Creator (Professional)** profile. No follower minimum. High confidence. |
| Engagement | Likes, comments, views, saves are **pooled to one count** visible identically across all collaborator profiles. Not split. High confidence. |
| Invite mechanic | Inviter composes → "Tag People" → "Invite Collaborator" → up to 5. Invitee accepts via DM-style notification. Post appears on host's feed immediately, on invitee's feed only after acceptance. High confidence. |
| Invite expiry | One source says pending invites expire at 14 days, another says no expiration. Treat as time-limited in practice. Medium confidence. |
| **Algorithmic bias** | Distribution appears to **favor the host/original poster's audience**, not the accepter's. Medium confidence (single primary source, FutureSocial blog, but mechanistically plausible). |

**Operating rule for asymmetric Collabs**: when the brand (small) is
collabing with a creator (larger audience), **the creator hosts and invites
MomRise**, not the other way around. This biases the algorithm toward
pushing into the creator's audience first, which is the bigger pool. This is
medium-confidence — test by A/B-ing 4 Collabs each way and measuring reach
split.

### A5. Collab vs. Branded Content tag — when to use which

Both should be used. They're parallel partnership formats, not substitutes.
Meta's 2025 Partnership Ads Hub now surfaces both in the "recommended" tab
together. (High confidence — Marketing Dive primary report.)

- **Use Collab** when the content is created with the brand as co-equal
  participant. Both audiences should see it. Example: a creator's Reel
  featuring the app, both want it on their feed.
- **Use Branded Content tag (Paid Partnership)** on top of Collab, OR
  standalone when the content lives only on the creator's feed but the
  relationship needs disclosure. Required any time the creator received any
  compensation, including rev-share. Two-sided permission required (creator
  opts in via Settings → Creator → Branded Content, brand approves).
- **Use both** for any rev-share code post. Collab for distribution, Branded
  Content for compliance.

### A6. Paid amplification via Meta Partnership Ads Hub

2025 feature, high confidence (Marketing Dive). Worth knowing exists, defer
implementation:

- Creators can share ad codes with brand advertisers, granting permission to
  boost the creator's tagged or untagged posts as paid ads.
- For high-performing rev-share Collabs (say, a Collab post that drives 20+
  subs through VESEL67), request the creator's ad code and boost with $50-100
  paid spend.
- Hands-on validation needed before committing real budget — UX of the
  ad-code workflow not yet documented in the verified sources.

---

## B. Pinterest — organic install funnel

**Goal reframe (2026-06-03)**: Pinterest's only job is driving organic
installs of the MomRise app. It is NOT a creator amplification channel
(that's IG's job). The audience is Pinterest searchers looking for recipe
ideas, who don't follow MomRise or our creators on anything. They convert
when a recipe pin lands them on a momrise.app page with a working install
CTA. Everything in this section flows from that goal.

### B1. The architecture — pins are install funnel entries, not content

```
Recipe in MomRise database
     │
     └── Generates a momrise.app/r/{slug}/ landing page (schema'd as Rich Pin)
              │
              └── Pinned to Pinterest (image + linked URL)
                     │
                     └── Pinterest searcher sees Rich Pin (auto-shows ingredients,
                         cook time, yield from schema)
                            │
                            └── Click → momrise.app/r/{slug}/
                                   │
                                   └── "Open in MomRise" CTA → app install
                                           │
                                           └── Recipe already in their account
```

The leverage is the long tail: every recipe in the database can be a
landing page that ranks for its specific search intent on Pinterest. 100
recipes → 100 landing pages → 100 micro-funnels.

### B2. The "machine" — Phase 1 build (REQUIRED for this model)

Pinterest as an install funnel doesn't work without recipe landing pages
that carry valid schema markup. Phase 1 build:

- **1a — Recipe landing page renderer** at `momrise.app/r/{slug}/` with
  schema.org/Recipe JSON-LD, Open Graph tags, install CTAs
- **1b — Rich Pin domain validation** via Pinterest's URL Debugger (one-time)
- **1c — Pin generator tool** (admin or creator dashboard) that takes a
  recipe ID and outputs the URL + a downloadable 1000×1500 pin image

See `admin/pinterest-recipe-pages-spec.md` for the full technical spec.

Phase 2 (defer): creator-dashboard "Pinterest Studio" tab where creators
publish their own recipes to /r/ pages.

### B3. Verified Pinterest core (still applies)

These four are high-confidence from the research and unchanged:

1. **Pin dimensions**: 2:3 vertical, **1000×1500 px** (600×900 min). Video
   pins 9:16, 1080×1920.
2. **Long-tail keywords** from Pinterest's own search autocomplete dominate
   SEO. Specifically-named boards rank, generic boards don't.
3. **Timeline**: 24-48h freshness boost per pin → 2-4 weeks for new pins
   to gain traction → 3-6 months for compounding.
4. **Rich Pins** lift recipe-niche engagement ~20-30% over standard pins
   (widely cited, directional).

### B4. Pin volume — corrected from earlier overstatement

The right framework is NOT "X pins per week." It's: **pin every genuinely
unique, search-matched, well-photographed recipe — once, to its best-matching
board — then stop until the next new recipe is ready.**

Why the cadence prescriptions don't apply:
- Volume of UNIQUE pins correlates with traffic (each is a different
  search-intent funnel).
- Volume of RECYCLED pins doesn't, and Pinterest's 2023 algorithm
  reportedly penalizes near-duplicates.
- Spam-pinning the same image to many boards historically throttled
  accounts.

So the operating model:

- **Phase 0 (before machine ships)**: 5-7/week, manually, from Reels' still
  frames. Bootstrap only — accept that some duplication is happening because
  we don't have the engine yet.
- **Phase 1 (machine live)**: Pin every recipe Haley flags as "published_to_web"
  once. Initial backfill of the first 50-100 recipes might take 2-3 weeks
  of pin sessions. After backfill, weekly volume = however many new
  published recipes happened that week (often single-digit). Quality of
  recipe + photo + keyword match >> raw pin count.
- **Phase 2 (creator dashboard tab)**: each creator publishes pages for
  their own attributed recipes. Volume scales with the creator program,
  not with Haley's manual capacity.

### B4b. Periodic re-pinning (the legitimate volume lever)

After a recipe page has been live for a month and has data:
- If it earned saves/clicks in its first board, pin it to 1-2 ADJACENT
  boards with a different image angle and headline. Pinterest treats
  meaningfully recontextualized pins as fresh signal.
- If it earned nothing, kill it. Don't re-pin underperformers.

This is the "more pins per recipe" that actually works — but it's
data-driven, not volume-for-volume's-sake.

### B5. Boards stay as planned

The 10 specifically-named boards from Haley's Day 2 setup are still right.
Don't rename them. They're the keyword targeting that determines which
search intent each pin shows up for.

### B6. Success metric — installs, not impressions

The Pinterest metric that matters is:

```
Pinterest impressions → /r/{slug}/ page views → app installs
```

Set up a tracking parameter on every pin URL (`?src=pinterest&board={board}`)
and log it in Firebase Analytics. The funnel becomes measurable. After
30 days, look at conversion rate per board and double down on the top 3.

Vanity metrics (impressions, saves, repins) are interesting but secondary.
A pin with 10,000 impressions and zero installs is a failed pin in this
model.

### B7. What Haley actually does for Pinterest

Reframed for the machine-live model:

- **Week 1-2 (pre-machine)**: Boards setup, domain claim with Collin, 1
  bootstrap pin from her first Cook With Me Reel. Total: ~2 hours.
- **Week 3+ (machine live)**: 30-minute weekly batch using the pin
  generator tool. Pick 20-30 recipes, generate pages, download images,
  upload to Pinterest, schedule across the week. Done.
- **Cook With Me Reels do NOT feed Pinterest under this model**. They
  feed IG and the creator library. Pinterest is a separate production
  pipeline driven by the recipe catalog, not by Haley's filming sessions.

### B8. Why "the machine" beats Haley-makes-pins-from-Reels

Three reasons:
1. **Scale**: the recipe database has hundreds of recipes; Haley's filming
   capacity is 1 per week. The machine multiplies output by 20-40×.
2. **Rich Pins**: Reel stills don't have Recipe schema. They're just
   pretty pictures. Recipe landing pages do, and they get the engagement
   lift that comes with it.
3. **Tracking**: a pin pointing to `momrise.app/r/{slug}?src=pinterest`
   produces measurable installs. A pin pointing to Haley's IG post doesn't.

---

## C. Creator playbook — what to ask creators to do

### C1. One-page brief (copy this verbatim into Notion/Drive for each creator)

```
You're an affiliate of MomRise earning 50% rev share on code [CODE].

For every post featuring the code, you MUST:

  1. Tag MomRise as a Paid Partnership (Settings → Creator → Branded Content
     → invite @momrise as branded partner). One-time setup. This is required
     by Instagram any time you're compensated in any form, including rev
     share.

  2. Put #ad and the word "Affiliate" at the START of every caption, before
     any other text:

         #ad Affiliate of @momrise — use code [CODE] for [benefit].

  3. For Reels, include on-screen text saying "Paid partnership" or "#ad"
     visible for the full duration of the video — not just at the end.

This protects both of us under FTC rules. Instagram's label alone is NOT
enough; the FTC requires the in-caption disclosure plus the video overlay.

We prefer that YOU host Collab posts and invite @momrise (not the other way
around) — Instagram pushes Collab content toward the host's audience first,
so this gets you more reach.

Suggested formats that perform:
  • "What I Feed My Kids This Week" (carousel or Reel)
  • Cook With Me — one recipe from the app, POV cooking, 30-60s
  • "Pulling a recipe from TikTok into MomRise" — demos the share extension
```

### C2. Disclosure language — what's safe to use, what to avoid

| Term | Use? | Why |
|---|---|---|
| `#ad` | Yes, required | FTC-validated, unambiguous |
| `Affiliate` / `Affiliate of` | Yes | Clear, FTC-validated for rev-share |
| `Partner` / `Paid partnership` | Yes | Matches Instagram's label terminology |
| `Ambassador` | Only with `#ad` | FTC has flagged "ambassador" alone as ambiguous |
| `Sponsored` | Yes | Acceptable for paid-relationship |
| `In collaboration with` | Yes, but not alone | Pair with `#ad` |
| Just the Paid Partnership label, nothing in caption | **NO** | Instagram explicitly positions the label as transparency, NOT FTC-sufficient disclosure |

### C3. Creator brief tooling

Single-page Notion doc per creator with:
- Their referral code
- Pre-written caption templates (3-5) with disclosure already embedded
- Latest 4-5 brand-side Reels they can Collab on
- Links to the brand's high-performing Reels in case they want to remix
- Their pending earnings + last payout date (pull from Firestore via the
  existing creator dashboard — link instead of duplicate)

Don't use a vendor platform (Brandbassador, etc.) until at least 20 active
creators. Notion + Google Drive is sufficient and won't burn budget on
infrastructure that's overkill at this scale.

---

## D. FTC compliance summary — the exact snippets

**Caption disclosure (first line, before any other text)**:

```
#ad Affiliate of @momrise — use code [CODE] for [benefit].
```

**Reel on-screen overlay (persistent, first 3 seconds AND again at code
reveal)**:

```
Paid partnership · #ad
```

**Branded Content / Paid Partnership label**: Creator opts in via
Settings → Creator → Branded Content. Brand approves. Label appears
automatically on tagged posts. Required by Instagram for any compensation
form including rev-share. NOT sufficient for FTC on its own — caption +
overlay still required.

**Brand-side joint liability**: When MomRise is the named Branded Content
partner, the brand shares liability for the creator's disclosure failure
under FTC enforcement patterns. This is why the creator brief is mandatory
distribution to every active creator.

---

## E. Open questions to revisit

| Question | Why it matters |
|---|---|
| What posting cadence actually maximizes creator Collab-acceptance rates? | 3-4/week is inferred, not measured. A/B-test 2/week vs. 4/week across 6 weeks once we have ≥10 active creators. |
| Does "host-first algorithmic bias" hold for asymmetric pairings (brand smaller than creator)? | Determines whether the creator should always host. Test by running 4 Collabs brand-as-host and 4 creator-as-host, measure reach distribution. |
| What's the actual Pinterest meal-planning cadence? | Zero verified. Become our own benchmark — measure from day 1 in the funnel. |
| Partnership Ads Hub creator-code workflow UX? | Marketing Dive confirms the feature exists, didn't document operator UX. Hands-on validation needed before paid amplification. |

---

## G. Asset library — structure and content (the "supply chain")

The Drive (or Notion) folder creators pull from. Two tiers; gating in
section H.

### G1. Tier 1 — generic, swappable parts (the parts bin)

Everything in Tier 1 is intentionally **unbranded by the creator** — it has
no creator-specific identity, so any creator can paste it into their post.
Their face/voice/style stays front-and-center; MomRise content is filler.

**Folder layout**:

```
/MomRise Creator Library
  /1 — App screen recordings (no audio)
    share-from-tiktok-to-momrise-7s.mp4
    recipe-to-grocery-list-9s.mp4
    grocery-list-to-instacart-6s.mp4
    meal-plan-week-scroll-5s.mp4
    family-setup-walkthrough-8s.mp4
    ...
  /2 — Brand elements
    momrise-logo-fade.mov  (transparent BG)
    outro-card-template.canva-link
    "I use code [CODE]" sticker template (PSD + PNG)
  /3 — Caption snippets with disclosure
    captions-with-ftc-disclosure.md
  /4 — Performance metadata
    audio-tracks-that-have-worked.md  (with IG audio IDs)
    hashtag-sets.md
    on-screen-text-style-guide.png
  /5 — Examples (what creators have done)
    @creator1-recipe-import-reel.mp4
    @creator2-cook-with-me.mp4
    ...
```

Asset characteristics:
- **No audio** on app screen recordings — so creator's voiceover dominates
- **5-15 seconds each** — short enough to splice anywhere
- **Vertical 9:16** — IG/Reel native, no reformat needed
- **No MomRise watermark** in the bottom-corner — creator credits via tag

### G2. Tier 2 — creator-personalized finished assets (one-offs)

When a creator earns Tier 2 access (see H), Haley produces a finished Reel
that looks like THEY made it:

1. Haley watches 5-10 of their existing posts, reverse-engineers visual style
2. Edits a 30-60s Reel: their face/voice (via short phone clip they send)
   + MomRise app content + their style fonts/transitions/color grading
3. Sends draft: "Does this feel like you?"
4. Iterates once
5. Creator hosts the Collab and publishes

To the algorithm and to the creator's audience, it's their content.

**Time budget**: ~2 hours of Haley's editing per Tier 2 asset. Don't promise
more than 2 Tier 2 assets per creator per month.

### G3. Featured-creator-in-frame is the precondition

For any amplification mechanic (Collab, repost, boost) to translate into
creator follower growth, **the creator has to be recognizably present in
the content** — face, voice, name on-screen, or distinctive style.

This means:
- A repost of a hands-only recipe Reel barely helps the creator
- A Tier 2 asset without any creator personalization is wasted Haley time
- The strongest Tier 1 outputs are the ones where the creator's voiceover
  + face-cam + the MomRise B-roll combine

**Operating rule**: every asset MomRise produces or amplifies should have
a clearly identifiable creator in it. If it doesn't, treat it as MomRise
content with zero creator-growth value — not as creator amplification.

---

## H. Tier 1 vs Tier 2 — performance gating

Tier 2 (custom editing) is the reward for performance, not a fixed-cost
burden on Haley's time.

| Creator state | Tier access | What they get |
|---|---|---|
| Just signed up, no posts yet | Tier 1 only | Drive link, captions, "go look at MomRise's last 6 Reels for the format" |
| 1-2 posts, low engagement | Tier 1 + check-in DM | Haley reaches out: "anything I can help with?" |
| Drove ≥5 subs in last 30 days | Tier 2 unlock | One Haley-edited Reel offer / month |
| Drove ≥20 subs in last 30 days | Standing Tier 2 | Proactive monthly co-production |
| Drove ≥50 subs in last 30 days | + paid amplification | Partnership Ads Hub boost ($50-100) on top performers |

Why the thresholds:

- **5 subs/30 days × 50% rev share × $69.99/year × 0.85 Apple cut ≈ $149 to
  the creator over a year** from one month's activity. Worth a 2-hour
  Haley edit to compound that.
- **20 subs/30 days × same math ≈ $595/year to the creator.** Worth a
  standing relationship.
- **50 subs/30 days ≈ $1,490/year** — at this point the creator is real
  business and paid boost ROI makes sense.

Below 5 subs/30 days, the asymmetric editing ROI doesn't justify the time
yet, but Tier 1 is genuinely sufficient for a casual creator who's not
performance-tier.

---

## I. Brand IG as showroom — what the Mon/Wed/Fri posts are actually for

MomRise's IG feed is NOT optimized for end-user reach or follower growth.
It's a creator training surface that doubles as public proof-of-life.

Two functions per post:
1. Public proof MomRise is real and active (legitimacy)
2. A live example of "this is what your post should look like" — the
   assembled-product version of the parts in the library

So the success metric for a MomRise feed post isn't likes or follows.
It's "how many creators referenced or mimicked this format this month."

**Reframed cadence**: 3-4 posts/week still right, but now every brand-side
post is also a Tier 1 library asset. Haley shoots, MomRise feed posts the
final cut, the unaudio'd screen-recording cuts go into the parts bin. One
production pass, two outputs.

Concrete success metrics worth tracking monthly:
- Number of active creators who pulled an asset from the library
- Number of creator posts that visibly used a library element
- Number of creators who DM'd Haley about Tier 2 unlock
- (NOT follower count on MomRise's account)

---

## F. Source-quality calibration notes

| Section | Sources | Confidence |
|---|---|---|
| Collab mechanics (cap, formats, engagement pooling, invite flow) | Instagram Help + 3 secondary | High |
| Paid Partnership label requirement | creators.instagram.com (primary) | High |
| Label NOT sufficient for FTC | Instagram primary + Luthor + IZEA + AdAmigo | High |
| Algorithmic bias toward host | FutureSocial (single primary blog) | Medium |
| "3x engagement" Meta-attributed stat | Widely cited, no primary whitepaper located | Medium |
| 14-day invite expiry | Conflicting sources | Medium |
| Content format precedents (WIEIAD, Cook With Me) | impulze.ai (single blog), formats widely documented | Medium |
| Graza launch precedent | Marketing Brew + Inside Retail + SARAL | High |
| Brand-IG cadence (3-4/week) | Synthesis of 13 verified claims | Low (inferred) |
| Pinterest day-by-day | None survived verification | Don't promise |
