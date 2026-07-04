# Research — Orchestration & Definition of Done

Orchestrate existing skills/tools per role; prefer the skill if installed, else run the pass manually against `rubric.md`. Nothing here is assumed installed — every skill is advised, not required. **Why each is advised, and a session availability check, live in [`../core/orchestration.md`](../core/orchestration.md)** (run by `craft-init`).

## Role → skill map

| Role | Preferred skill/tool (if present) | Fallback |
| :--- | :--- | :--- |
| Multi-pass research engine | `deep-research` — *strongly advised, see registry* | run the passes manually: query set → gather → score → synthesize |
| Domain research agents | VoltAgent `market-researcher` / `technical-writer` — *see registry* | — |
| Evidence gathering | `WebSearch` / `WebFetch` (built-in); `context7` for library/API docs | — |
| Output formatting | `docx` · `pdf` · `xlsx` | markdown |
| Review loop | `plannotator` (annotate the draft report) | manual critique against the rubric |
| Brain-dump intake · question stress-test | `capture` · `grill-me` (or any skill filling the role) | structure / stress-test manually |

> Source-credibility scoring, claim→source traceability, and counter-argument coverage are **baked into `rubric.md`**, so the pack is self-sufficient. `deep-research` is the recommended install because its multi-pass pipeline materially raises rigor and citation quality.

> **Use `context7` for any library/framework/API/tooling questions** — per the project rule, fetch current docs rather than answering technical specifics from memory.

## Definition of Done
Done only when, in a single clean review round:
- [ ] Every dimension in `rubric.md` passes (question/scope, evidence quality, traceability, reasoning/balance, synthesis).
- [ ] Every material claim is cited and verifiable; zero fabricated or misattributed sources.
- [ ] Hypotheses were tested against disconfirming evidence, and counter-arguments are addressed.
- [ ] The bottom-line answer leads, and every planned sub-question is resolved or explicitly left open.
- [ ] The user has signed off on the findings (per-pass) or the completed report (autonomous).
