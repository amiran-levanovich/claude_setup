# Experience-Design — Orchestration & Definition of Done

This pack **orchestrates** existing skills; it does not reinvent design tooling. For each role, prefer the skill if it's installed, otherwise fall back to producing manually against `rubric.md` (same pattern as the code workflow's review table). Nothing here is assumed installed — every skill is advised, not required. **Why each is advised, and a session availability check, live in [`../core/orchestration.md`](../core/orchestration.md)** (run by `craft-init`).

## Role → skill map

| Role                                                       | Preferred skill (if present)                                  | Fallback                                                      |
| :--------------------------------------------------------- | :------------------------------------------------------------ | :------------------------------------------------------------ |
| Frontend design engine (produce · critique · live-iterate) | `impeccable` — *strongly advised, see registry*               | produce and critique against the rubric directly              |
| Visual / UI production                                     | `frontend-design` · `web-artifacts-builder` · `canvas-design` | hand-build against the rubric                                 |
| Brand / visual system                                      | `brand-guidelines` · `theme-factory`                          | apply the project's design tokens manually                    |
| Journey mapping · heuristic critique · a11y audit          | `design-skills` — *recommended, see registry*                 | the frameworks are baked into `rubric.md` — critique manually |
| Deep UI/UX agents                                          | VoltAgent `ui-designer` / `ux-researcher` — *see registry*    | —                                                             |
| Review loop                                                | `plannotator` (annotate the rendered design)                  | manual critique against the rubric                            |
| Brain-dump intake · brief stress-test                      | `capture` · `grill-me` (or any skill filling the role)        | structure / stress-test manually                              |

> The Nielsen heuristics, WCAG 2.2 AA checks, JTBD, and journey-coherence criteria are **baked into `rubric.md`**, so this pack is self-sufficient. `cuellarfr/design-skills` deepens the critique when installed but is never required.

## Definition of Done
The deliverable is done only when, in a single clean review round:
- [ ] Every dimension in `rubric.md` passes (goal/hierarchy, Nielsen heuristics, journey, critical states, WCAG 2.2 AA, responsiveness/brand).
- [ ] All three critical states (empty/loading/error) exist for the key elements.
- [ ] The primary action is unmistakable at every breakpoint.
- [ ] Any deviation from the brand/design system is recorded as a decision in the living doc.
- [ ] The user has signed off on the final surface (per-pass) or the completed deliverable (autonomous).
