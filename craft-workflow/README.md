# craft-workflow

> Part of the [**claude_setup**](../README.md) marketplace. Sibling plugin: [**dev-workflow**](../dev-workflow/README.md) (code).

A Claude Code plugin that brings the discipline of the `dev-workflow` kit to **non-code deliverables** — design, content, and research. Same spine (understand → plan → criteria-first → produce → review loop); the code-specific machinery (git gates, test suites) is replaced by **agent-run gates**, because non-code quality is a judgment, not a shell check.

It supplies the **method** and concrete **acceptance rubrics**, and **orchestrates existing skills** for the actual craft — it never reinvents design or copywriting.

> Sibling of `dev-workflow` in the same marketplace. Install whichever you need; they don't cross-trigger.

---

## The one idea

Define what "good" looks like **before** you produce. In code that's a failing test; here it's an explicit **acceptance rubric**. Producing before the rubric exists is the same mistake as writing implementation before the test.

## The five steps (`craft_docs/core/craft_workflow.md`)

1. **Discovery & brief** → interview, write `craft/<name>.md`, **sign-off gate** before producing.
2. **Plan** as a resumable living doc (atomic pieces, decisions, dead-ends, open questions). Close-out promotes durable rules to `CLAUDE.md` and captures confirmed, generalizable **project lessons** into `craft/lessons.md` — read back at the start of every later deliverable.
3. **Criteria-first** → write the piece's rubric (the "test") before producing it.
4. **Produce → check → iterate** → produce, check against the rubric yourself, fix, present.
5. **Completion review loop** → critique the whole deliverable against the domain rubric, report → fix → re-review until a clean round.

Context tight or resuming lost? [`craft_docs/core/quickref.md`](./craft_docs/core/quickref.md) is the distilled 9-rule floor with a "when lost" protocol — the sibling of `dev-workflow`'s 10-rule quickref.

## Domains

| Pack | Covers | Baked-in rubric frameworks |
|---|---|---|
| **experience-design** | UI/visual design, UX flows, user journeys, accessibility | Nielsen's 10 heuristics · WCAG 2.2 AA · Jobs-to-be-Done · journey coherence |
| **content** | long-form writing, marketing/landing copy, UX microcopy, SEO | UX-writing 4 standards · SEO search-intent + E-E-A-T · benefits-over-features |
| **research** | investigation, evidence weighing, synthesis, reports | source-credibility scoring · claim→source traceability · counter-argument coverage |

Each pack has `brief.md` (discovery + template), `rubric.md` (the acceptance criteria), and `toolchain.md` (orchestration + definition of done). A task can span packs — web work is usually `experience-design` + `content`.

## Skills

| Skill | When it triggers |
|---|---|
| `craft-init` | Start of a deliverable — discovery, brief, sign-off |
| `craft-iterate` | Producing/iterating each piece against its rubric |
| `craft-review` | The completion critique-and-fix loop before "done" |

## Orchestration — what it drives

**Assumes nothing is installed.** Every pack is self-sufficient via its baked-in rubric; the skills below are *advised*, not required, and each prefers-if-present with a graceful fallback (same pattern as `dev-workflow`'s review table). `craft-init` runs a **session availability check** at the start of each deliverable and reports which advised skills are present vs missing — the full registry, with *why each is advised* and install pointers, is [`craft_docs/core/orchestration.md`](./craft_docs/core/orchestration.md).

Advised external installs that materially upgrade output:

| Domain | Recommended install | What it adds |
|---|---|---|
| experience-design | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | design critique/audit/polish commands, live browser iteration, deterministic detector rules |
| content | [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) | copywriting, CRO, SEO |
| research | [daymade deep-research](https://github.com/daymade/claude-code-skills) | multi-pass pipeline, source scoring |
| design / research | [VoltAgent subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) | ui-designer, ux-researcher, market-researcher agents |
| experience-design | [cuellarfr/design-skills](https://github.com/cuellarfr/design-skills) | heuristic critique, journey mapping, a11y |
| content (UX copy) | [content-designer/ux-writing-skill](https://github.com/content-designer/ux-writing-skill) | 4-standard microcopy framework |

It also drives, **when available** (all optional):

- Anthropic skills: `frontend-design`, `canvas-design`, `brand-guidelines`, `web-artifacts-builder`, `doc-coauthoring`, `internal-comms`.
- By capability role: annotation review (e.g. `plannotator`), brief stress-test (e.g. `grill-me`), brain-dump intake (e.g. `capture`) — any skill filling the role works, whatever its name.

None are hard requirements — the packs degrade to their baked-in rubrics. The rationale for each lives in the [registry](./craft_docs/core/orchestration.md).

## Install

```
/plugin marketplace add amiran-levanovich/claude_setup
/plugin install craft-workflow@claude-setup
```

Then just describe a non-code task ("design a landing page for…", "write an SEO article on…", "research whether…") and `craft-init` takes it from discovery through sign-off.

## What it deliberately does **not** have

- **No pre-commit hook.** Nothing deterministic to check — all enforcement is the agent-run sign-off gates and review loop.
- **No fixer agents.** There's no auto-corrector for prose or pixels; the review loop is the mechanism.
