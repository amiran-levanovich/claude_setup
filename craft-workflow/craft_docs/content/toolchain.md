# Content — Orchestration & Definition of Done

Orchestrate existing skills per role; prefer the skill if installed, else write manually against `rubric.md`. Nothing here is assumed installed — every skill is advised, not required. **Why each is advised, and a session availability check, live in [`../core/orchestration.md`](../core/orchestration.md)** (run by `craft-init`).

## Role → skill map

| Role | Preferred skill (if present) | Fallback |
| :--- | :--- | :--- |
| Marketing/landing copy · CRO · SEO | [`coreyhaines31/marketingskills`](https://github.com/coreyhaines31/marketingskills) — *recommended install (34.7k★)*: `copywriting`, `copy-editing`, `cro`, `seo-audit`, `ai-seo`, `programmatic-seo`, `schema` | write against the marketing + seo rubric sections |
| UX microcopy | [`content-designer/ux-writing-skill`](https://github.com/content-designer/ux-writing-skill) — *optional install*: the 4-standard framework + UI-copy patterns | the 4 standards are baked into `rubric.md` |
| Long-form structure & house formats | `doc-coauthoring` (structured co-authoring), `internal-comms` (company formats) | outline-first, write against the Always rubric |
| Document output | `docx` · `pdf` · `pptx` (when a formatted file is the deliverable) | markdown |
| Review loop | `plannotator` (annotate the draft) | manual critique against the rubric |
| Brain-dump intake · brief stress-test | `capture` · `grill-me` | — |

> The UX-writing 4 standards and the SEO search-intent/E-E-A-T checklist are **baked into `rubric.md`**, so the pack is self-sufficient. `marketingskills` is the recommended install because it materially upgrades landing/SEO/CRO production.

## Definition of Done
Done only when, in a single clean review round:
- [ ] The **Always** rubric passes, plus every applicable sub-mode section (marketing / ux-microcopy / seo).
- [ ] Every factual claim traces to a source in the brief — zero fabricated facts.
- [ ] Structure was approved as an outline before full prose (for anything beyond a few lines).
- [ ] For SEO pieces: title tag + meta description written; heading hierarchy validated; intent match confirmed.
- [ ] The user has signed off on the final copy (per-pass) or the completed deliverable (autonomous).
