# Orchestration Registry — advised skills & the availability check

This plugin assumes **nothing is installed**. Every pack is fully self-sufficient: the acceptance rubrics in each `<domain>/rubric.md` bake in the frameworks (Nielsen heuristics, WCAG 2.2, the UX-writing standards, SEO E-E-A-T, source-credibility scoring), so the workflow runs end-to-end with zero external skills.

The skills below are **advised, not required** — each raises output quality for one role. This file is the single registry of *what each adds and what happens without it*; the dev sibling is `agent_docs/core/orchestration.md`.

> **Principle:** the kernel supplies the *method*; these skills supply the *craft*. We never reinvent design, copywriting, or research engines — we drive the best available one, and degrade gracefully to the rubric when it's absent.

## The availability check (run by `craft-init`)

1. Determine the deliverable's domain(s) (Step 0 of the kernel).
2. Inspect the **skills and tools actually available to you this session** (your available-skills list and built-in tools).
3. For each advised entry relevant to those domains, mark **Available ✓** or **Not present**.
4. Report a compact table: role, skill, present/absent — with the one-line "adds" and install pointer for anything missing.
5. **Never block.** Proceed with the baked-in rubric regardless. Only *offer* to pause if a **strongly-advised** engine (`impeccable`, `marketingskills`, `deep-research`) is missing and the user might want it first.

Install paths vary (plugin marketplace, `npx skills add …`, or copying into `.claude/skills/`); follow each repo's README. A capability may exist under a different name (workspaces often namespace skills) — any equivalent skill filling the same role counts.

## Cross-cutting (all domains)

### Annotation review — e.g. `plannotator`
- **Adds:** precise, per-section human annotations on the rendered design or draft for the Step 5 loop — tracked, specific, actionable.
- **Install:** [backnotprop/plannotator](https://github.com/backnotprop/plannotator)
- **Without it:** critique manually against `<domain>/rubric.md`; present findings as a prioritized list.

### Brief stress-test — e.g. `grill-me`
- **Adds:** pressure-tests a thin brief before sign-off, surfacing assumptions that would derail production halfway through.
- **Without it:** self-review the brief against its success criteria before sign-off.

### Brain-dump intake — e.g. `capture`
- **Adds:** converts an unstructured stream of ideas into a clean brief without losing items.
- **Without it:** structure the dump into the brief template yourself.

## experience-design

### Frontend design engine — `impeccable` (**strongly advised**)
- **Adds:** design guidance built for AI coding agents — `critique`/`audit` for the Step 5 review loop, `polish`/`typeset`/`colorize`/`layout` for production, `live` for in-browser iteration, plus 45 deterministic detector rules (the closest thing design work gets to a lint floor).
- **Install:** `npx impeccable install` ([pbakaus/impeccable](https://github.com/pbakaus/impeccable)); its `/impeccable init` design-context docs (PRODUCT.md/DESIGN.md) complement the brief — reuse the brief's answers there, don't duplicate.
- **Without it:** produce and critique against `rubric.md` directly.

### UI / visual production — `frontend-design`, `web-artifacts-builder`, `canvas-design` (Anthropic skills)
- **Adds:** polished, real UI (React/Tailwind/shadcn) or static visual artifacts built on actual design principles.
- **Without them:** build against the rubric directly; the quality bar still holds.

### Brand / visual system — `brand-guidelines`, `theme-factory`
- **Adds:** consistent color/typography systems so output is on-brand, not default-looking.
- **Without them:** apply the project's existing design tokens manually.

### Heuristic critique · journey mapping · a11y — `design-skills`
- **Adds:** structured Nielsen-heuristic critique, WCAG 2.2 audits, and journey-mapping passes.
- **Install:** [cuellarfr/design-skills](https://github.com/cuellarfr/design-skills)
- **Without it:** the frameworks are baked into `rubric.md` — critique manually.

### Deep design/research agents — VoltAgent `ui-designer` / `ux-researcher`
- **Adds:** specialized agents for deeper interface and user-research work.
- **Install:** [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)

## content

### Marketing copy · CRO · SEO — `marketingskills` (**strongly advised**)
- **Adds:** battle-tested headline/CTA formulas, CRO patterns, and SEO/E-E-A-T checklists — materially better than generic prose for landing/SEO/conversion work.
- **Install:** [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills)
- **Without it:** write against the marketing + seo sections of `rubric.md`.

### UX microcopy — `ux-writing-skill`
- **Adds:** the 4-standard microcopy framework plus UI-copy patterns (buttons, errors, empty states), applied consistently.
- **Install:** [content-designer/ux-writing-skill](https://github.com/content-designer/ux-writing-skill)
- **Without it:** the 4 standards are baked into `rubric.md`.

### Long-form structure — `doc-coauthoring`, `internal-comms` (Anthropic skills)
- **Adds:** structured long-form co-authoring and company-standard internal formats.
- **Without them:** outline-first, write against the Always rubric.

### Formatted output — `docx`, `pdf`, `pptx`
- **Adds:** the actual formatted file when that's the deliverable. **Without them:** deliver markdown.

## research

### Research engine — `deep-research` (**strongly advised**)
- **Adds:** multi-pass pipeline with source-credibility scoring, parallel drafting, and citation enforcement — materially higher rigor than ad-hoc search.
- **Install:** [daymade/claude-code-skills](https://github.com/daymade/claude-code-skills)
- **Without it:** run the passes manually: query set → gather → score → synthesize against `rubric.md`.

### Domain agents — VoltAgent `market-researcher` / `technical-writer`
- **Adds:** specialized market and technical research/writing agents.
- **Install:** [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)

### Evidence gathering — `WebSearch`, `WebFetch` (built-in), `context7` (MCP)
- **Adds:** always-available primitives for gathering and citing evidence; `context7` for current library/API docs.

### Formatted output — `docx`, `pdf`, `xlsx`
- **Adds:** the report/sheet when that's the deliverable. **Without them:** deliver markdown.
