# Recipe Enrichment Engine ("Food Genome") — Build Spec (for Collin)

*From Brennan + Claude, 2026-08-13. The likely answer to the recipe-DB problem: instead of SOURCING a structured recipe library, MANUFACTURE one from recipes that flow in via usage. Also the hero "make any recipe kid-ready" feature. Photos are NOT solved here — that stays the creator-original-photography path.*

## Why this solves the recipe-DB problem (the key reframe)
The recipe *facts* — ingredient list + cooking steps — are **NOT copyrightable** (established US doctrine; only the written prose, headnotes, and photos are protected). So the engine can legally:
1. **Ingest any recipe** (mom/creator upload, URL import, or photo),
2. **Extract the free facts** (ingredients + steps),
3. **Re-express them in MomRise's own structure** (independent writeup — not a reword of the source),
4. **Enrich** them into a kid-tuned, spec'd entry.

The structured recipe DB becomes an **OUTPUT of the engine + usage**, not a library you have to license or source. It grows with use, is genuinely differentiated (kid-tuned + personalized), and normalizes messy UGC into consistent structured recipes. **That is the moat** — and it sidesteps the sourcing gate entirely. (Photos remain the one thing this doesn't produce — see guardrails.)

## Pipeline
1. **Input:** text upload · URL import (fetch + parse) · photo (vision/OCR extract).
2. **Extract to facts:** structured ingredients (qty + item) + ordered steps. Facts only.
3. **Normalize:** map ingredients → **USDA FoodData Central** entities (CC0, free, public-domain) for nutrition.
4. **Re-express:** generate MomRise's OWN structured writeup — genuinely independent, not a reword of the source prose.
5. **Enrich (the value layers):**
   - Nutrition (USDA-derived) — deterministic
   - Portion scaling — deterministic math
   - Age-appropriateness — rules + AI
   - **Allergen flags — VALIDATED RULES** (ingredient→allergen map, the big-9). NOT raw AI.
   - **Choking-hazard flags BY AGE — VALIDATED RULES** (known hazard list by age). NOT raw AI.
   - Picky-eater substitutions + kid-appeal tweaks — AI
   - Personalization — filter/adapt to the family's child profile (ages, allergies, prefs) → "make this right for my 2- and 5-year-old"
6. **Safety-validation gate:** allergens, choking hazards, and nutrition come from validated data/rules, never AI guesses; low-confidence items flagged for review. **Safety-critical** — a wrong allergen or choking-hazard flag is a liability + trust disaster, so this layer is rules/data, not generative.
7. **Store:** proprietary structured schema — normalized ingredients, steps, nutrition, tags (age/allergen/hazard/dietary/prep-time/mess), enriched metadata, source provenance.

## Legal guardrails (get the standard lawyer-approved)
- Store **FACTS only** (ingredients, steps). Never store or copy source **prose or photos**.
- **Re-expression must be genuine** (independent structure + writeup), not a light reword of a single source — "rewriting at scale from one source" risks derivative-work/substantial-similarity claims. Prefer the user's own input or multi-source.
- UGC uploads sit behind the **ToS license grant + DMCA safe harbor** (per the recipe-legal research).
- **Photos:** facts are free, photos are not — so imagery stays the **creator-original-photography** path. This engine does not manufacture photos.

## Cold-start
Seed with creator-contributed originals + a small curated set so the DB isn't empty at launch; usage compounds it from there.

## What it delivers
- The hero **"make any recipe kid-ready + right for MY kids"** feature — differentiation + a personalization/switching-cost moat.
- A **proprietary, structured, kid-tuned recipe DB that grows with usage** — no licensed library required.
- **Consistent structured recipes** (fixes UGC messiness) = also the non-thin data layer for meal-led programmatic SEO.
- Remaining gap: **photos** → creator-photography path.
