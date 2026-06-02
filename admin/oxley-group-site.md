# Oxley Group Website Project

Side project for Barry Oxley — real estate website for "The Oxley Group" at Coldwell Banker Kennan & Parker Alliance. Captured here so the project can be picked up cold later.

---

## Project at a glance

- **Client:** Barry Oxley
- **Business:** The Oxley Group (real estate team, Barry + daughter, Alabama-registered LLC) operating under Coldwell Banker Kennan & Parker Alliance brokerage. Separate construction business too, but that's handled via marketing not a separate site.
- **Decision authority:** Barry has **sole** decision-making power. Confirmed.
- **Communication cadence:** Barry usually responds fast. **One caveat:** Brennan + kids are visiting all week (week of 2026-06-01), so Barry's communication is morning-only that week.
- **Status as of 2026-06-01:** Discovery done, architecture decided, no code yet, no domain registered yet.

---

## Discovery Q&A (Barry's verbatim answers)

### Brokerage compliance

**1. Coldwell Banker policy on agent sites?**
> They encourage agents to have their own websites. We just have to have the mandated logo and the Realtors logos.

→ No pre-approval needed. Must display CB logo + Realtors logo. **Significantly lighter compliance than typical CB franchises.**

**2. Listings on the site? IDX feed?**
> No, I would want it to connect with our company website for searches — kpdd.com

→ **No IDX needed.** Site links out to kpdd.com (the brokerage's MLS search) for any listing search. This removes the biggest cost + complexity item from the build.

**3. "Each Office Independently Owned and Operated" disclaimer required?**
> No that statement no

→ Just CB logo + Realtors logo. No disclaimer footer required.

### Team

**4. Team page?**
> The Oxley Group is myself and daughter. We have FB and Insta accounts. It's also registered with the state of Alabama name wise.

→ Two-person team. Has existing FB + Instagram presence we can embed.

**5. Service area?**
> Anywhere within 60 miles of Lee County.

→ Auburn / Opelika / Lake Martin / surrounding. Useful for local SEO targeting.

**6. Differentiator?**
> Been in real estate business for over 20 years. Have experience with luxury, Investors, buyers and sellers.

→ 20-year experience as the trust hook. Generalist positioning across luxury / investor / buyer / seller.

### Site structure

**7. Primary visitor action?**
> All of the above. Mainly contact directory

→ Contact form is the primary CTA. Phone, calendar, listing search via kpdd link, CMA request are all secondary.

**8. Listings — all-market or own only?**
> All listings

→ Links to kpdd.com for full MLS search (no listings managed on this site).

**9. Lead routing?**
> Direct email to me

→ Forms email Barry directly. No CRM integration required for v1.

### Practical

**10. Domain?**
> The Oxley Group?? Some illeteration of that?

→ **Not registered yet.** Need to grab one. Candidates: `theoxleygroup.com`, `oxleygrouphomes.com`, `oxleygroupauburn.com`, `oxleygroupre.com`. Suggest registering before someone else does.

**11. Photos / assets?**
> Have photos and social media stuff.

→ Has personal photos + social media content available. May still want a fresh team headshot for the home hero.

**12. Timeline?**
> Sooner the better.

→ Aim for 2-3 weeks to launch.

**13. Maintenance?**
> Open to discuss.

→ We'll propose "we handle updates as needed, no recurring retainer required" since real estate brochure sites don't change often.

**14. Budget?**
> Have zero idea.

→ We frame it: $1,000-1,500 one-time + $0/mo ongoing.

---

## Decisions made

### Tech stack: custom on our pattern, NOT Squarespace

Use the same pattern as momrise.app, projectpulsehq.app, keystonepro:

- HTML/CSS/JS site (no framework needed for a brochure site)
- GitHub repo (e.g., `oxleygroup-site`)
- Deploy via **GitHub Pages** or **Vercel** (free tier)
- Domain via Namecheap or Cloudflare, ~$12-15/yr
- Contact form via **Formspree** or **Vercel Function** (free for low volume)
- Embed Barry's existing FB + Instagram feeds for social proof + freshness

**Why not Squarespace:**
- $0/mo hosting vs $23-49/mo (saves $1,500-3,000 over 5 years)
- Full design control (no template constraints)
- Same tooling we already use for other sites
- Trade-off: Barry can't self-edit content via WYSIWYG — but real estate brochure content rarely changes, and we can handle updates on request

### Site structure (5 pages) — full page-by-page spec

#### Page 1 — Home
**Purpose:** First impression. Capture lead intent within ~30 seconds of arrival. Establish trust through the 20-year hook + family-business positioning.

**Sections (top to bottom):**

1. **Hero block** — Barry + daughter photo (warm, professional, not stiff stock-headshot style). Headline: "20+ years helping families call Lee County home." Subhead: "The Oxley Group at Coldwell Banker Kennan & Parker Alliance." Two CTAs: primary "Get in touch" button → Contact form, secondary "Browse listings →" → kpdd.com.
2. **Three quick-action tiles** — large cards stacked or in a row: "I want to buy" / "I want to sell" / "Search Lee County listings." Each tile is one tap to either Contact or kpdd. Removes the "where do I start?" friction.
3. **The Oxley Group story (short)** — 2-3 sentences. Father-daughter team, 20+ years between them, focus on Auburn/Opelika/Lake Martin area, warm but real.
4. **Services overview** — 4 small cards: Buyer / Seller / Investor / Luxury. Each card is a teaser that links into the Services page.
5. **Featured testimonials (2-3)** — short quotes with first name + city. Sourced from his existing past-client list. Strong social proof early in scroll.
6. **Local area showcase** — photo strip or grid showing Auburn / Opelika / Lake Martin / Lee County rural — visual cue that this is THE local team, not an out-of-area pop-up.
7. **Instagram feed embed** — embedded grid of his existing IG posts. Keeps site visually "alive" without him having to write blog posts.
8. **Contact CTA block (footer-ish)** — name + email + short message form, or "Call (XXX) XXX-XXXX" + email button.

---

#### Page 2 — About
**Purpose:** Where someone considering working with him goes to verify. Establishes trust, tells the family-business story, shows the team is real humans.

**Sections:**

1. **Page header** — "Meet the Oxley Group"
2. **Barry's bio** — 2-3 paragraphs. Years in real estate, what kinds of clients he's worked with (luxury / investors / first-time buyers), philosophy, optional personal note (family, community involvement, what he does outside work).
3. **Daughter's bio** — 1-2 paragraphs. Her role, what she brings, why she joined the team.
4. **The family-business angle** — Short block explaining what it means to work with a father-daughter team. "Two generations, one phone call." This is a real differentiator — most CB teams are partnerships or solo agents.
5. **Credentials** — CB Kennan & Parker Alliance affiliation, Realtor designation (NAR), any specific certs (luxury, investor, etc.), Alabama LLC registration confirmation.
6. **Photos** — team headshot, candid working-together shot, optional "around town" image.
7. **Service area map** — visual map of Lee County + 60-mile radius. Communicates "we work HERE, not generic statewide spam."
8. **CTA block** — "Have a question? Let's talk." + Contact form link.

---

#### Page 3 — Services
**Purpose:** Match the visitor to the right service path. Explain what working with the Oxley Group actually looks like for their specific need.

**Sections:**

1. **Page header** — "How we work"
2. **Buyer services** — Short paragraph + "What to expect" 3-4 bullets (e.g., "Local market briefing", "Curated listings from MLS", "Showings on your schedule", "Negotiation experience from 20+ years of deals"). Per-section CTA: "Start a buyer search →"
3. **Seller services** — Pricing strategy, marketing approach, expected timeline. Bullets: "Free CMA (Comparative Market Analysis)", "Professional listing photography", "Strategic pricing for the local market", "Negotiation through to close". CTA: "Get a free CMA →"
4. **Investor services** — Investment property analysis for the area, rental yield insights, knowledge of Auburn rental market (university town driver). Bullets: "Investment property scouting", "Rental yield analysis", "Property management referrals", "1031 exchange experience". CTA: "Talk investments →"
5. **Luxury services** — Discreet, white-glove approach, market connections. Bullets: "Off-market and pocket listings", "Discreet showings", "Lake Martin and high-end Auburn/Opelika expertise", "Marketing to qualified buyers". CTA: "Discuss a private listing →"
6. **Cross-cutting CTA at bottom** — "Not sure which fits? Just call." + contact info.

---

#### Page 4 — Resources / Blog (optional in v1, recommended for SEO)
**Purpose:** SEO honeypot. Capture long-tail Google searches like "buying a home in Auburn AL" / "Lake Martin real estate trends" / "Auburn school districts for families." Long-term lead source.

**Sections:**

1. **Page header** — "Real estate insights"
2. **Blog post grid** — 3-6 articles displayed as cards (image, title, date, 1-2 sentence excerpt). Each card links to a full article page.
3. **Initial 4-6 articles to publish at launch** (can write with AI assist, Barry reviews/edits):
   - "Lake Martin waterfront market 2026: What's selling and what's sitting"
   - "Best Auburn neighborhoods for families with school-age kids"
   - "What '20 years in Lee County real estate' actually means for buyers"
   - "Investing in Opelika rental properties: 5 things to know before you buy"
   - "Selling your home this fall? Three things Lee County sellers get wrong"
   - "Working with a father-daughter team: what to expect" (the Oxley Group origin piece)
4. **Tag/category navigation** (optional) — Buying / Selling / Investing / Local market / Lake Martin
5. **Newsletter signup** (optional) — "Get our quarterly Lee County market update" (would tie into the referral-nurture marketing play)

**Note:** Resources page is OPTIONAL for v1. If timeline matters more than SEO, ship the other 4 pages and add this later. But long-term it's where 80% of organic search lands.

---

#### Page 5 — Contact
**Purpose:** Remove every friction point between "I want to reach out" and Barry's inbox.

**Sections:**

1. **Page header** — "Let's talk" (warmer than "Contact Us")
2. **Primary contact form** with fields:
   - Name (required)
   - Email (required)
   - Phone (optional but recommended)
   - "What can we help with?" dropdown (Buying / Selling / Investing / Just curious / Other)
   - Message (free text)
   - Submit button → emails Barry directly via Formspree or Vercel Function
3. **Direct contact info block** — Barry's phone number (click-to-call on mobile), email (click to mailto), office address (CB Kennan & Parker Alliance office).
4. **Service area map** — same map as About page, or a smaller version. "We serve a 60-mile radius around Lee County."
5. **Social links** — Facebook + Instagram (visible icons linking to his existing accounts).
6. **Hours of availability** — "Calls Monday-Friday 9 AM – 7 PM. Forms anytime."
7. **Footer compliance block** — CB logo, Realtors logo, copyright line "© 2026 The Oxley Group", "Each member of the Oxley Group is a licensed real estate professional in the State of Alabama" disclaimer.

---

### Cross-cutting elements (every page)

**Persistent top nav bar:**
- Logo (Oxley Group) — clicks back to Home
- Home / About / Services / Resources / Contact
- Right-aligned: "Search listings" button → kpdd.com (external)

**Persistent footer:**
- CB logo (mandated) + Realtors logo (mandated)
- Brokerage attribution: "The Oxley Group is part of Coldwell Banker Kennan & Parker Alliance"
- Social links (FB, IG)
- Copyright line
- Privacy + ToS links (boilerplate)

**Mobile considerations:**
- Hamburger menu collapses the nav on phone widths
- Contact form should be one tap from the home page on mobile
- IG embed should render acceptably on mobile (Instagram's embed is mobile-friendly by default)

### Brand requirements (from Coldwell Banker)

- ✅ Display CB logo (mandated)
- ✅ Display Realtors logo (mandated)
- ❌ NOT required: "Each Office Independently Owned and Operated" disclaimer

### Budget framing for Barry

| Option | One-time | Monthly | Trade-offs |
|---|---|---|---|
| **Recommended: custom HTML/CSS on GitHub Pages** | $1,000-1,500 | $0 (just domain ~$15/yr) | Full design control, we update on request |
| Optional retainer | — | $50-100/mo | Quarterly content refresh + tech maintenance |

5-year total: ~$1,000-1,500 + $75 domain = under $1,600 vs Squarespace's $1,500-3,000 hosting alone.

---

## Marketing strategy (separate from the website)

### CRM verdict: skip Lofty/Followup Boss

Barry's current state:
- **Has a CRM that works** (likely MoxiEngage via CB brokerage)
- Gets **2-4 leads/week, "crap quality"**

→ Lofty's AI lead scoring solves "I'm drowning in leads, which to call back?" Barry has the opposite problem: too few good leads. Lead-management AI doesn't help. **Recommend skipping Lofty entirely.**

### The real marketing pivot: lead QUALITY, not management

| Channel | Cost | Why |
|---|---|---|
| **Google Business Profile** | Free | Single biggest local-SEO lever. Get reviews from past clients. |
| **Google Performance Max** | $500-1,500/mo ad spend | Captures intent ("homes for sale Auburn AL"). AI optimizes inside Google. |
| **Meta geo-targeted ads** | $300-800/mo ad spend | Lake Martin / family home photos targeted to 30-55yo in Lee County area |
| **Local SEO blog/content** | $0 + time | "Best schools in Auburn", "Lake Martin waterfront market 2026" |
| **Referral nurture** | $0 + time | Past clients — quarterly market email. Best leads come from referrals already. |
| **Cancel underperforming sources** | Save $200-400/mo | If paying for Zillow Premier Agent or Realtor.com Connections, those are likely the "crap quality" source. |

**Total monthly ad spend:** ~$800-2,300, replacing whatever's currently spent on low-quality lead sources. Same dollars, better channels.

### Open marketing question to ask Barry

> "What lead sources are you currently paying for? Zillow Premier Agent, Realtor.com Connections, brokerage-supplied leads?"

The answer tells us exactly what to cancel and where to redirect.

---

## What I'd tell Barry next (when picking this back up)

Two follow-up emails to send:

### Email 1 — Website kickoff

> Thanks for the detailed answers. Since you don't need MLS listings on the site (kpdd.com handles search), this is a much simpler build than I'd expected. Plan to deliver:
>
> - 5-page professional site: Home / About / Services / Resources / Contact
> - Contact form emails you directly
> - Embedded FB + Instagram feeds so the site stays "alive"
> - Built on the same stack we use for our other sites — net-zero ongoing hosting cost
>
> **Cost: $1,000-1,500 one-time + ~$15/yr for the domain.** No recurring monthly fees. I'll handle any content updates you email me about (real estate brochure sites don't change much).
>
> **Timeline: 2-3 weeks to launch.**
>
> **Domain — I'd grab one before someone else does. My picks:**
> 1. `theoxleygroup.com`
> 2. `oxleygrouphomes.com`
> 3. `oxleygroupauburn.com`
>
> Pick one and I'll register it tonight. Or any preference you'd like to add.

### Email 2 — Marketing pivot

> On the marketing side — since you already have a working CRM, skip Lofty. The 2-4 crap-quality leads/week tells me your problem is lead QUALITY, not lead management. Lofty's AI scoring helps when you have lots of leads to triage; doesn't help when the leads themselves are bad.
>
> The real move: figure out which sources are generating the bad leads (Zillow Premier Agent? Realtor.com Connections? Brokerage routing?) and redirect that budget to higher-quality channels — Google Business Profile reviews, Google Performance Max ads, geo-targeted Meta ads in your 60-mile radius. Net spend stays similar, but the leads that come in actually convert.
>
> **Quick question first:** What lead sources are you currently paying for? Once I know what's driving the crap quality, I can give you a real reallocation plan.

---

## Open items / next steps

- [ ] Register a domain (one of the candidates above)
- [ ] Get Barry to pick a domain + send Email 1
- [ ] Get Barry's current paid-lead-source list + send Email 2
- [ ] Spin up the `oxleygroup-site` GitHub repo with a base template (can borrow patterns from `consciousmamaapp.github.io` website pages — `/creator/index.html`, `/apply/`, etc.)
- [ ] Get CB and Realtors logos from Barry (PNG/SVG)
- [ ] Schedule a 30-min call to walk through the wireframe before building

## Notes for whoever picks this up later

- **Brand voice direction:** Barry is established, trusted, 20+ years experience. Tone should match: warm but professional, not flashy or salesy. Auburn/Opelika is a smaller market — "local family business" vibe lands better than "luxury urban realtor" aesthetics.
- **Don't promise weekly content updates or social media management** — this is a brochure site, not a managed marketing service. Set expectations early.
- **Construction business** is separate. If Barry asks for that too, it's a similar build but different positioning (referral-heavy, would link to portfolio of past builds rather than CMA forms). Don't combine.
- **The "AI marketing" pitch fatigue is real** — Barry's been spam-pitched for years. Every recommendation needs transparent pricing and an obvious "why" or he'll bounce.
