# Orchestration Registry — advised skills & the availability check

This plugin assumes **nothing is installed**. Every pack is fully self-sufficient: the acceptance rubrics in each `<domain>/rubric.md` bake in the frameworks (Nielsen heuristics, WCAG 2.2, the UX-writing standards, SEO E-E-A-T, source-credibility scoring), so the workflow runs end-to-end with zero external skills.

The skills below are **advised, not required** — each one materially raises output quality for a specific role. This file is the single registry of *what each adds, why it's worth installing, and what happens without it*. `craft-init` runs the availability check at the start of every deliverable and reports which advised skills are present.

> **Principle:** the kernel supplies the *method*; these skills supply the *craft*. We never reinvent design, copywriting, or research engines — we drive the best available one, and degrade gracefully to the rubric when it's absent.

---

## The availability check (run by `craft-init`)

1. Determine the deliverable's domain(s) (Step 0 of the kernel).
2. Inspect the **skills and tools actually available to you this session** (your available-skills list and built-in tools).
3. For each advised entry relevant to those domains, mark **Available ✓** or **Not present**.
4. Report a compact table to the user: the role, the skill, present/absent, and — for anything missing — the one-line rationale and install pointer below.
5. **Never block.** Proceed with the baked-in rubric regardless. Only *offer* to pause if a **strongly-advised** engine (`marketingskills`, `deep-research`) is missing and the user might want it first.

Install paths vary by skill (Claude Code plugin marketplace, `npx skills add …`, or copying into `.claude/skills/`); follow each repo's README. When a skill names a capability you don't have under that exact name, any equivalent skill filling the same role works just as well.

---

## Cross-cutting (all domains)

| Skill / capability | Why advised | If absent |
| :--- | :--- | :--- |
| **Annotation review** — e.g. `plannotator` ([backnotprop/plannotator](https://github.com/backnotprop/plannotator)) | Turns the Step 5 review loop from vague back-and-forth into precise, per-section human annotations on the rendered design or draft — tracked, specific, actionable. | Critique manually against `<domain>/rubric.md` and present findings as a prioritized list. |
| **Brief stress-test** — e.g. a plan-interrogation skill (`grill-me`) | Pressure-tests a thin brief before sign-off, surfacing unstated assumptions that would otherwise derail production halfway through. | Self-review the brief against the rubric's success criteria before sign-off. |
| **Brain-dump intake** — e.g. a capture/organizer skill (`capture`) | Converts an unstructured stream of ideas into a clean brief without losing items. | Structure the dump into the brief template yourself. |

## experience-design

| Role | Advised skill | Why advised | If absent |
| :--- | :--- | :--- | :--- |
| UI / visual production | `frontend-design`, `web-artifacts-builder`, `canvas-design` (Anthropic skills) | Produce polished, real UI (React/Tailwind/shadcn) or static visual artifacts using actual design principles — far better than hand-rolled markup. | Build against the rubric directly; quality bar still enforced. |
| Brand / visual system | `brand-guidelines`, `theme-factory` | Apply consistent color/typography systems so output is on-brand, not default-looking. | Use the project's existing design tokens manually. |
| Heuristic critique · journey · a11y | [`cuellarfr/design-skills`](https://github.com/cuellarfr/design-skills) (35★) | Adds structured Nielsen-heuristic critique, WCAG 2.2 audits, and journey-mapping passes. | The frameworks are baked into `rubric.md` — critique manually. |
| Deep design/research agents | [`VoltAgent`](https://github.com/VoltAgent/awesome-claude-code-subagents) `ui-designer`/`ux-researcher` (22.3k★) | Specialized agents for deeper interface and user-research work. | — |

## content

| Role | Advised skill | Why advised | If absent |
| :--- | :--- | :--- | :--- |
| Marketing copy · CRO · SEO | [`coreyhaines31/marketingskills`](https://github.com/coreyhaines31/marketingskills) (34.7k★) — **strongly advised** | Battle-tested headline/CTA formulas, CRO patterns, and SEO/E-E-A-T checklists — materially better than generic prose for landing/SEO/conversion work. | Write against the marketing + SEO sections of `rubric.md`. |
| UX microcopy | [`content-designer/ux-writing-skill`](https://github.com/content-designer/ux-writing-skill) (117★) | Enforces the 4-standard microcopy framework + UI-copy patterns (buttons, errors, empty states) consistently. | The 4 standards are baked into `rubric.md`. |
| Long-form structure | `doc-coauthoring`, `internal-comms` (Anthropic skills) | Structured long-form co-authoring and company-standard internal formats. | Outline-first, write against the Always rubric. |
| Formatted output | `docx`, `pdf`, `pptx` | Produce the actual formatted file when that's the deliverable. | Deliver markdown. |

## research

| Role | Advised skill | Why advised | If absent |
| :--- | :--- | :--- | :--- |
| Research engine | [`daymade/claude-code-skills` deep-research](https://github.com/daymade/claude-code-skills) (2.6k★) — **strongly advised** | Multi-pass pipeline with source-credibility scoring, parallel drafting, and citation enforcement — materially higher rigor than ad-hoc search. | Run the passes manually: query set → gather → score → synthesize against `rubric.md`. |
| Domain agents | [`VoltAgent`](https://github.com/VoltAgent/awesome-claude-code-subagents) `market-researcher`/`technical-writer` (22.3k★) | Specialized market and technical research/writing agents. | — |
| Evidence gathering | `WebSearch`, `WebFetch` (built-in), `context7` (MCP, for library/API docs) | Always-available primitives for gathering and citing evidence. | — (built-ins are normally present) |
| Formatted output | `docx`, `pdf`, `xlsx` | Produce the report/sheet when that's the deliverable. | Deliver markdown. |
