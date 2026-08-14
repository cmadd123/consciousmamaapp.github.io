# Comparison-Authority Engine — Shared Build Spec (RoofWorks + MomRise)

*From Brennan + Claude, 2026-08-13. The WiFiHotshots play, built as a reusable engine for BOTH ventures. Core thesis: the moat isn't the comparison PAGES — it's the living, always-current, machine-readable DATA LAYER underneath (the "category graph"). Build the graph once; pages, tools, feeds, and AI citations flow from it. Cost guardrails baked in (cheap-model + data-driven). [BUILD=Collin]*

## The five components

### 1. The category graph (the data layer = the real moat)
A structured, machine-readable dataset of every entity in the category (products / tools / methods) and their attributes (specs, prices, features, warranties, nutrition, guidelines). Auto-updated. This is the foundation everything else reads from — build it as a proper data model, not as page content.
- Schema per entity: id, name, category, source-provenance, attributes{...}, last-verified timestamp, confidence.
- **Facts only** (specs/prices/nutrition/features) — legal to aggregate (not copyrightable). Never store protected prose/photos.

### 2. Aggregation pipeline (cheap — mostly HTTP + parsing)
Fetch + parse authoritative source data into the graph. Minimal LLM (only for extraction/normalization of messy inputs). Respect robots.txt/ToS (contract nuance). Multi-source where possible for accuracy + to avoid single-source derivative risk.

### 3. Page generation (from the graph — one-time, cheap model)
Generate, all AEO-structured (answer-first, comparison tables, schema, disclosed-fair where we're a participant):
- **Head-to-head** "A vs B"
- **"Best X for [need]"** roundups
- **"[Incumbent] alternatives"**
- **Long-tail** "best X for [specific constraint]" (thousands of hyper-specific, zero-competition, LLM-answerable pages)
- **Gap-analysis** "what no [category] tool does" → maps the full capability matrix, owns the white-space/underserved-need queries (where our own product wins)
- **Cost guardrail:** bulk generation on a CHEAP model (Haiku/Sonnet), Opus reserved for high-value only. Only generate pages the graph has real data + demand for (non-thin gate).

### 4. Decision engine (interactive tool — rules-based, near-zero runtime cost)
"Tell me your situation → best X for you." User inputs constraints → **rules/filtering over the graph** (NOT an LLM per query) → ranked recommendation. Spawns infinite long-tail landing pages, captures leads, is a self-replicating linkable asset. The tool itself is a moat.

### 5. Freshness + first-mover loop
- Scheduled re-fetch of source data → detect changes → **regenerate only affected pages** (incremental, cheap).
- Detect NEW entrants/products → **auto-generate their comparisons first** (own new "A vs B" queries before anyone).
- Freshness = 3.2x AI citations, and an always-current source beats every static-page incumbent.

## Make it the source others ingest (upstream authority)
Publish the graph as `Dataset` schema (+ optionally a feed/API) so LLMs and other sites pull from us as the origin — cited across the whole category, not just per query. This is the highest-ceiling piece: become the substrate of the category, not a page in it.

## Self-tuning (leading → lagging, same as everything else)
Tie page/tool performance to the citation radar + downstream conversion. Leading indicators first (citations, rankings, tool completions, clicks), back-propagate expected value as conversion history accrues. Learn which comparisons drive signups/report-claims → auto-expand there. Guardrail: validate leading metrics still correlate with conversion.

## Self-participant guardrail (both ventures)
When comparing a category we're in: **disclose it and stay genuinely fair** (win on real dimensions, concede others — fairness earns citation AND trust AND converts the right customers), OR keep neutral-authority content on non-participant categories and treat "[us] vs X" as honest positioning. Never fake-neutral.

## Per-venture instantiation
**RoofWorks — two graphs, two goals:**
- Homeowner graph (shingle brands, roof materials, insurance concepts) → funnel to **free report**. Neutral (we're not a shingle brand).
- Roofer graph (roofing lead-gen / CRM / hail-detection / drone software) → funnel to **roofer signup** (inbound roofer acquisition — complements manual outreach). Self-participant guardrail applies. Queries: "best roofing lead generation 2026," "Loveland vs IMGING," "AccuLynx vs JobNimbus," "[competitor] alternative."

**MomRise — non-participant, adjacent categories:**
- Parenting graph (baby/kid gear specs, nutrition panels + ingredient lists, AAP/pediatric method guidelines) → funnel to **app signup**. Focus method comparisons (least covered, most LLM-queried) + adjacent products. Queries: "Formula A vs B," "best high chairs for baby-led weaning," "baby-led weaning vs purées."

## Cost summary
One-time bulk generation ~$50–250 for ~5k pages (cheap model); recurring citation radar ~tens of $/mo; aggregation + decision engine near-free (HTTP + rules). Real cost = Collin's build time, amortized across BOTH ventures.
