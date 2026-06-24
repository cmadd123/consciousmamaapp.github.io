# Baby Mode — In-App Disclaimer Copy

Paste-ready disclaimer language for the Baby Mode v1 surfaces. Designed to pair with the Section 7a additions to the public Terms of Service.

The goal: legally defensible without an RD review, friendly enough to not scare parents.

---

## A. Baby Mode setup — one-time acknowledgement screen

Shown on first activation of Baby Mode (after adding a baby profile, before any feeding guidance is shown).

> **Before we get started**
>
> Baby Mode shows ideas and general guidance for what your baby might be ready to eat. It's not medical advice and it's not a replacement for your pediatrician.
>
> A few things to keep in mind:
>
> • **You decide what's right for your baby.** Babies develop at different rates. Trust your pediatrician and your own judgment.
> • **Always supervise meals.** Choking can happen with any food, no matter how it's cut. Stay with your baby every time.
> • **Allergies need a doctor.** If your baby has known allergies or you're concerned about a new food, talk to your pediatrician or allergist first.
> • **We cite our sources.** Where we reference the American Academy of Pediatrics or CDC guidance, we'll show you. Always check the original source if anything's unclear.
>
> [ ] **I understand and want to use Baby Mode.**
>
> [Continue]   [Skip Baby Mode]

The checkbox must be tapped to proceed. Store acknowledgement + timestamp on the user doc (`baby_mode_terms_accepted_at`) so we can prove they saw it.

---

## B. Per-screen persistent footer

Shown subtly at the bottom of every Baby Mode screen (recipe baby-view, food detail, allergen log, etc.). Quiet but always present.

> Educational only — not medical advice. Always supervise your baby during meals. [Why we say this →](/terms.html#section-7a)

Link goes to the Terms of Service Section 7a anchor.

---

## C. Food detail screen — choking-risk callout

Shown when a user views a specific food that carries documented choking risk (grapes, hot dogs, hard raw vegetables, nuts, etc.).

> **⚠ Choking risk**
>
> [Food name] is a common choking hazard for babies and young children. Even when cut as suggested, supervision is essential.
>
> [AAP guidance →](https://www.healthychildren.org/English/health-issues/injuries-emergencies/Pages/Choking-Prevention.aspx)

---

## D. Allergen log — first allergen entry

Shown when a user logs the first introduction of a known top-9 allergen (peanut, egg, dairy, soy, wheat, tree nut, sesame, fish, shellfish).

> **Introducing an allergen**
>
> [Allergen] is one of the top 9 most common food allergens. Before introducing it for the first time:
>
> • Talk to your pediatrician, especially if your baby has eczema, a family history of allergies, or other risk factors
> • Offer it at a time when you can watch your baby for at least 2 hours afterward
> • Have a plan if you notice a reaction (rash, swelling, vomiting, breathing changes — call 911 for severe reactions)
>
> Your log here is for tracking only, not medical guidance. [Learn more from AAP →](https://www.healthychildren.org/English/healthy-living/nutrition/Pages/Introducing-Allergens-to-Your-Baby.aspx)

---

## E. "Baby view" on family recipes

Shown when a user taps the "Baby (Xmo)" chip on a family recipe to see what their baby can eat.

> **For [Baby Name], age [Xmo]**
>
> Based on this recipe, here's what's typically considered baby-appropriate at this age. Always check with your pediatrician for specific guidance, and supervise eating closely.
>
> [List of safe ingredients with cut/serve guidance]
>
> Skip for baby:
> • [List of ingredients to omit — added salt, raw items, honey under 12mo, etc.]

Notice the language: "typically considered" and "always check with your pediatrician" — defensive without being alarming.

---

## F. App Store description (Baby Mode section)

If/when Baby Mode is in the App Store listing description, lead with this framing so the listing matches the in-app voice:

> **Baby Mode for solids (6+ months)**
>
> See which ingredients on tonight's family dinner your baby can eat, how to cut them, and what to swap. Log first foods and track allergen introductions. Reviewed by [Pediatric RD Name], with citations to American Academy of Pediatrics guidance throughout.
>
> Educational only — always consult your pediatrician for medical advice.

---

## G. Marketing language to AVOID

These phrases create medical-claim risk and should never appear in MomRise's Baby Mode:

- ❌ "Safe for your baby" (implies guarantee)
- ❌ "Doctor-approved" (unless a specific licensed doctor has reviewed and you can name them)
- ❌ "Allergy-safe" (implies medical screening)
- ❌ "Prevents choking" (no app prevents choking)
- ❌ "Pediatrician-recommended" (unless you have a specific pediatrician endorsing)
- ❌ "Diagnose" / "Treat" / "Cure" anything

Acceptable alternatives:

- ✅ "Typically recommended for ages X+"
- ✅ "Reviewed by [Name, RDN]"
- ✅ "Cited from AAP guidance"
- ✅ "Commonly considered a choking hazard — see AAP guide"
- ✅ "Top 9 allergen — talk to your pediatrician before introducing"

---

## H. Implementation checklist

- [ ] One-time acknowledgement screen on first Baby Mode activation
- [ ] Persistent footer text on every Baby Mode screen
- [ ] Choking-risk callout for documented hazard foods
- [ ] Allergen intro callout on top-9 allergen log
- [ ] "Baby view" defensive language on family recipes
- [ ] Store acknowledgement timestamp on user doc
- [ ] Link every disclaimer to Terms Section 7a anchor
- [ ] Cite AAP or CDC source on every cut/serve guideline (visible to user)
- [ ] If RD-reviewed: add "Reviewed by [Name], RDN" attribution on every food card
- [ ] Marketing copy passes the avoid-list above

---

## I. If we don't get RD review

The above is sufficient legally — strong disclaimers, AAP citations on every guideline, indemnification in ToS, limitation of liability.

What we sacrifice:
- The "Reviewed by [Name], RDN" attribution line
- Marketing credibility with traditional moms
- Expert-witness defense if ever sued (RD review makes claims harder to attack)

The actual increased legal risk is small but non-zero. The bigger cost is reputational and competitive (Solid Starts has feeding therapists; we have disclaimers).

If budget is genuinely tight, this version ships. Add RD review later as a "v1.1 — now reviewed by [Name]" relaunch moment.
