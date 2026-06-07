# MomRise Content — Haley's Starter Pack

Specific, ordered, no-strategy-fluff direction for what to actually do
this week and recurring after. Three workstreams: MomRise IG, MomRise
Pinterest, Creator Asset Library. They share most of the production
work — one filming session feeds all three.

Time-budgeted everywhere. If a step says "20 min" and you've been on it
for 45, ping Collin — something's wrong with the instructions, not you.

---

## 📅 First 7 Days — The Bootstrap Sequence

Get the foundations in place. After this week, you switch to the weekly
rhythm in the next section.

### Day 1 — Accounts (30 min total)

- [ ] **MomRise IG**: already set up (handled separately). Confirm it's a
  **Professional / Creator** account before posting (Settings → Account →
  Switch to Professional → "Creator"). Required for Collab posts and
  Insights. If it's already Professional, skip this step.
- [ ] **MomRise Pinterest**: set up a **Business** account at
  business.pinterest.com (you handle this). When you click "Claim your
  website," Pinterest gives you a unique verification token (either a TXT
  DNS record or an HTML meta tag). **DM Collin the token** — he adds it
  to momrise.app and you click verify. ~5 min round-trip.
- [ ] **Firebase Console** access — Collin already added you. Sign in at
  console.firebase.google.com → MomRise. Bookmark the **Storage** tab —
  this is where you'll upload videos for the Creator Library.
- [ ] **Canva account** (free tier is fine). Bookmark the link.
- [ ] **CapCut on your phone** (free). This is the video editor — easier
  than Reels' built-in editor and free.

### Day 2 — Pinterest boards (45 min)

On Pinterest, create these 10 boards. Names matter — these specific
phrases come from Pinterest's autocomplete and they rank where generic
ones don't.

- [ ] Easy Toddler Dinners
- [ ] Sheet Pan Family Meals
- [ ] Lunchbox Ideas for Picky Eaters
- [ ] 30-Minute Mom Recipes
- [ ] Make-Ahead Freezer Meals
- [ ] Healthy Meal Prep for Busy Moms
- [ ] Kid-Friendly Snacks Without Sugar
- [ ] Weeknight Dinner Ideas for Families
- [ ] One-Pan Recipes for Tired Moms
- [ ] Family Breakfast Ideas

Don't pin anything yet — just create the boards. Each gets a 1-sentence
description (Pinterest cares about board descriptions for SEO):
- "Quick, kid-approved dinners I actually make on weeknights" — style
- Keyword stuffing reads spammy. Write like a human.

### Day 3 — Storage folder (5 min)

In Firebase Console → Storage, the `creator_library/` folder already
exists (publicly readable, admin-write only — Collin set up the rule).

You don't need to create subfolders. When you upload a video, just name
it descriptively:

```
share-tiktok-to-momrise.mp4
recipe-to-grocery-list.mp4
hands-chopping-onion.mp4
```

After upload, click the file → copy the access URL (starts with
`https://firebasestorage.googleapis.com/...`) → paste it into
`creator/library/manifest.js` with a title and duration. Push the
repo. The Creator Library page picks it up on next load.

Live URL: **momrise.app/creator/library/** — that's what creators see.

### Day 4 — The 5 screen recordings (30 min, the easiest day)

Open MomRise on your phone. Hit record-screen. Do each of these once,
slowly. Save each as a separate clip. Trim with CapCut. Upload to
Firebase Storage at `creator_library/{filename}.mp4`, then add a row to
`creator/library/manifest.js` per the instructions on Day 3.

| Clip name | What to record | Target length |
|---|---|---|
| `1-share-tiktok-to-momrise.mp4` | Open TikTok, tap share on a recipe video, choose MomRise, see the recipe land | 7-10s |
| `2-recipe-to-grocery-list.mp4` | Open a recipe in MomRise, tap "add to grocery list," see it appear | 8-10s |
| `3-grocery-to-instacart.mp4` | Grocery list → "Send to Instacart" → see Instacart open with items | 6-8s |
| `4-meal-plan-week.mp4` | Scroll through one week of the meal plan view | 5-7s |
| `5-family-setup.mp4` | Quick demo of adding a child or family member | 8-10s |

**Critical**: no audio. Mute everything before you record. These get
voiceover'd by creators — your audio would conflict.

### Day 5 — Cook With Me Reel (90 min, the longest day)

Film ONE recipe Reel start-to-finish using a recipe you imported from
TikTok into MomRise. This will become your first MomRise IG post AND your
first "example" file for creators to reference.

Setup (10 min):
- Pick a recipe one of your existing creators (VESEL67's) made on TikTok.
  Import it via the share extension. Caption gets a creator credit.
- Phone on a tripod or stack of books, eye-level. Front-facing or back —
  doesn't matter, just consistent.
- Daylight if possible. Single warm bulb if not.

Film (45 min for a 45s Reel):
- 3-5 second hook: "I import all my recipes from TikTok now" or similar
- Quick cut to the share-from-tiktok screen recording you already shot
- You cooking the recipe: 5-6 short cuts (handling ingredients, pan,
  finished dish)
- 3 second outro: "Recipe imported from @[creator]. Code [CODE] in bio."

Edit (30 min in CapCut):
- Add the on-screen text overlay: `Paid partnership · #ad` in the top-right,
  visible the whole time
- Add captions (CapCut autocaptions, then proofread)
- Trim to 20-30 seconds — sweet spot for TikTok, still works for IG (single master cross-posts)

Post (5 min):
- Caption: `#ad Affiliate of @momrise — import recipes from TikTok in
  one tap. Recipe by @[creator]. Code [CODE] in bio.`
- Toggle Paid Partnership → tag @momrise (you're posting from MomRise's
  account, so tag your creator partner if applicable)
- Publish

> Note on language: the code is pure attribution — it doesn't unlock a
> trial or discount (the 7-day trial is universal). Don't say "for 7 days
> free" in captions; it implies a benefit the code doesn't actually
> provide. Honest framing only.

Once posted, copy the Reel's IG URL. Open
`creator/library/manifest.js`, add an entry under `examples:` with the
URL, your handle, and a one-line description. Commit + push. The Creator
Library's "Examples" section now shows your Reel as a format reference.

### Day 6 — One bootstrap pin (30 min)

**Note**: This week we're doing ONE pin from your Reel as a placeholder.
The real Pinterest workflow needs a recipe page generator we haven't
built yet (see `admin/pinterest-recipe-pages-spec.md` — Collin's task).
Once that's live, you'll switch to the machine workflow. Until then, this
one manual pin keeps your boards from being empty.

Pull a still frame from the Reel. Use Canva. Open a 1000×1500 design.

- The still as the background (faded slightly so text reads)
- Recipe name in large text at top
- "Imported from TikTok in MomRise" subtitle
- Small MomRise logo in bottom-right corner

Save as `pin-template-001.png`. Save the Canva design as a template too
— you'll reuse this layout for any manual bootstrap pins before the
machine ships.

Pin it to **two** of your boards (whichever two fit). Description:

```
[Recipe name] — imported from TikTok and into our family meal plan in
under 30 seconds with the MomRise share extension.
```

**Pin link**: until the recipe page renderer is live, link to
`momrise.app` (the homepage). Once `/r/{slug}` pages exist, you'll point
pins at those instead — and the same recipe gets a Rich Pin treatment
automatically.

### Day 7 — Review and reset (20 min)

- Scroll your MomRise IG feed: does the one post look right?
- Check Pinterest: is the pin live? Did it get any impressions?
  (Don't expect anything — week 1 is flat.)
- Add today's date to a tracking sheet (Drive: `weekly-metrics.csv`)
  with: IG followers, IG post views, Pinterest impressions, Pinterest
  saves. You'll update this weekly to learn your baseline.

---

## 🔁 Weekly Rhythm (after week 1)

Total: ~3-4 hours/week. Front-load on one day if that's easier than
spreading.

### One filming + editing session per week (2 hours)

Pick a recipe. Film a Cook With Me Reel using the same setup as Day 5.

Outputs from this one session:
- **1 finished Reel** → posts to MomRise IG that week
- **1 still frame** → becomes 1-2 Pinterest pins
- **Cooking B-roll cuts** → 2-3 short clips for `/4 — B-roll/`
  (hands-only, no face — reusable by creators who don't want to film
  their own B-roll)

### Pin batch (machine-driven)

Two rules:
1. Pin each new published recipe once, to its best-matching board.
2. Monthly, re-pin winners (saved/clicked pins) to 1-2 adjacent boards with a new image angle + headline. Kill losers.

**Before the machine is live** (Phase 0 only):

Make 4-6 pins/week. Mix:
- 2 from the week's Reel (different angles, different headlines)
- 2 from older Reels (recycle)
- 1-2 from MomRise app screenshots with text overlay

Link all of them to `momrise.app`. Once the machine ships, you'll
re-pin the strongest performers pointing at their proper recipe pages.

Schedule across the next 7 days, around 7-9pm local.

### One post on MomRise IG per week (you already filmed it in the
filming session — just publish)

Aim for **Tuesday or Thursday evening** — these tend to be highest-engagement
slots for parenting content. Not a rule, just a starting hypothesis.

### Carousel or app-demo post on alternate weeks (1 hour)

Every other week, instead of a Cook With Me Reel, post one of:
- "What I Feed My Toddler This Week" carousel (use 7 phone-shot meal
  photos from the week, last slide = MomRise weekly plan screenshot)
- "Pulling a recipe from TikTok into MomRise" 30-second demo Reel
- Behind-the-scenes "how I pick recipes for the week"

This keeps your feed mixed instead of all-Cook-With-Me.

### Asset library refresh (15 min, end of each week)

- Drop the week's hands-only B-roll cuts into `/4 — B-roll/`
- Save the week's finished Reel into `/5 — Tier 1 examples/`
- Update the caption snippets file (`/3`) if you wrote a hook that worked
  unusually well

---

## 🎬 The Parts Bin — First 10 Filming Targets

Some of these are already on the Day 4-5 list. Here's the full canonical
set to have in the library by end of week 2.

### App screen recordings (no audio) — 5 clips
Already covered in Day 4. Re-record any that didn't come out clean.

### Cook-with-me face-on Reels — at least 2 finished examples
- One simple weeknight meal (15-min dinner)
- One "kids actually ate this" win

### B-roll cuts (hands only, reusable) — 5 short clips
Film during the Cook With Me session, just point the phone at the action:

| Shot | Length | Why creators want it |
|---|---|---|
| Hands chopping onion | 3-4s | Universal recipe filler |
| Pan sizzling (any protein) | 3-4s | Sensory hook |
| Pouring olive oil into pan | 2-3s | Caption hook ("pour it on") |
| Spices being added to dish | 2-3s | Color + motion |
| Finished plated dish overhead | 4-5s | Closer/reveal shot |

### Brand elements — 2 reusable
- A 1-second MomRise logo fade in/out (Canva, white BG)
- A "code [CODE] · momrise.app" lower-third sticker (Canva PNG with
  transparent BG that creators can drop into their Reels)

### Caption snippets file (`/3 — Caption snippets/captions.md`)

Format: 5-6 hooks, each with FTC disclosure pre-embedded. Creators copy,
swap `[CODE]`, post.

```markdown
# Caption hooks for creators

Each starts with the required FTC disclosure. Pick one, swap [CODE]
with your code, customize the rest in your voice.

**About the code**: using [CODE] doesn't change anything for the person
typing it in — the 7-day free trial is universal and there's no discount.
The code is pure attribution: it tells MomRise the subscription came from
you, so your 50% rev share kicks in. Frame it honestly. Don't promise a
benefit the code doesn't actually provide.

---

#ad Affiliate of @momrise — code [CODE] supports my channel (free for you).

The 5pm scramble is over. I import recipes from TikTok in 10 seconds now
and our whole week's planned. If you try MomRise, [CODE] is my code.

---

#ad Affiliate of @momrise — using code [CODE] supports my channel at no
extra cost to you.

Lazy mom meal plan, going up. The MomRise app pulls recipes straight from
TikTok and Pinterest and turns them into grocery orders. I haven't planned
a week from scratch in three months.

---

#ad Affiliate of @momrise — code [CODE] is mine.

POV: every time you find a recipe on TikTok you can just save it to your
meal plan. Then it's on the grocery list. Then it's at your door. If you
subscribe, plug [CODE] in — supports me at no cost to you.

---

#ad Affiliate of @momrise — [CODE] is my code if you try it.

Things I stopped doing once I started using @momrise: writing grocery
lists, screenshotting recipes I never make, staring at the fridge at 5pm.

---

#ad Affiliate of @momrise — [CODE] supports my channel (free for you).

This is the only app I open in the morning. I look at the week, see what
I planned, and the recipe + ingredients are right there. Stops the
weekday lunch decision-fatigue at least.
```

---

## 🛠️ Tools — One-Time Setup

| Tool | Free? | What it's for | One-time setup |
|---|---|---|---|
| **Phone camera** | Yes | Filming Reels and pins | None |
| **CapCut** (iOS/Android) | Yes | Video editing, captions, overlay text | Install, sign in |
| **Canva** (web) | Yes | Pin design, brand graphic templates | Sign up, make 1000×1500 template |
| **Google Drive** | Yes | Asset library | Already done in Day 1 |
| **Pinterest Trends** (trends.pinterest.com) | Yes | Find what people are searching this week in your niche | Bookmark, check before each pin batch |
| **IG Insights** (in-app) | Yes | Track which posts work | Already in your IG settings |

Cheap upgrades to consider in month 2-3, not before:
- Small ring light (~$20) — only if your lighting is genuinely bad
- Pinterest scheduler in Tailwind (~$15/month) — only if you scale past
  10 pins/week

---

## 📊 Weekly Metrics — What to Track

Don't get fancy. One CSV row per week, takes 5 minutes:

| Week | IG followers | IG post views avg | Pinterest impressions | Pinterest saves | Creators who pulled from library | Notes |
|---|---|---|---|---|---|---|

After 4 weeks you'll see whether the cadence is working. Don't read into
weeks 1-2; everything is noise until ~week 4.

Success metric reminder (from the playbook): **the goal is not MomRise's
follower count. It's the number of creators who pulled assets from the
library and posted.** Track that explicitly.

---

## ❓ Common Roadblocks — Solve Before They Happen

**"I don't have time to film a whole Reel this week."**
→ Post a still-frame Pinterest pin from an older Reel. Skip the IG post.
Don't try to film when you're not in the mood — bad content is worse than
no content for your weekly slot.

**"The video looks bad."**
→ Better lighting is 80% of the fix. Stand near a window with the light
coming from the front, not behind you. If that's not possible, film in
the daytime in any kitchen with a north-facing window.

**"My voice over isn't smooth."**
→ Write a 3-bullet script and read it once before recording. Don't try to
freestyle if you're stiff — it'll feel awkward in playback. Three bullets
is enough; let the cooking footage fill the rest.

**"Creators aren't pulling from the library yet."**
→ Expected for weeks 1-4. Send the FAQ link explicitly to each active
creator the first time, ask "did this make sense?" — they'll tell you
what's confusing.

**"I'm not sure if a recipe is creator-branded enough."**
→ Ask: would someone watching this know who you are if they didn't already
follow you? If yes, post. If no, add a 1-second on-screen "@haley" sticker
in the first 3 seconds.

---

## 🚪 When to escalate to Collin

- A creator asks about money (payouts, earnings, code issues)
- A creator wants to leave the program
- Stripe / Apple support emails about anything financial
- You're more than 30 minutes over the time budget on any step here
- The Drive folder is full or messy and you want it reorganized

Things you don't need to escalate:
- Picking which recipes to film
- Choosing pin colors and layouts
- Whether to post on Tuesday or Wednesday
- Writing caption variations

---

## 📌 The One-Card Version (print this)

```
WEEKLY (3-4 hours):
  ☐ Film 1 Cook With Me Reel  → IG + library example
  ☐ Make 4-6 Pinterest pins   → schedule across 7 days
  ☐ Save B-roll cuts to Drive → library refresh
  ☐ Update weekly metrics CSV

EVERY POST (IG):
  ☐ Caption first line: #ad Affiliate of @momrise — code [CODE]
  ☐ Paid Partnership toggle ON, tag @momrise (or partner creator)
  ☐ On-screen text overlay: Paid partnership · #ad (full duration)

EVERY PIN (Pinterest):
  ☐ 1000×1500 vertical, recipe-card style
  ☐ Description = 1 natural sentence with the keyword from the
    board name
  ☐ Pin to 1-2 boards max, never spam-pin
```
