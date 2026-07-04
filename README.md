# claude_setup

A self-hosting Claude Code **plugin marketplace** built on one idea: take a single idea and iterate it into something worthy, with discipline — *understand → plan → define "good" up front → produce → review-loop until a clean pass.*

That method is the same whether you're shipping code or shipping a design, an article, or a research report. So the marketplace ships it as **two sibling plugins** — one for code, one for everything else:

| Plugin | For | Enforcement | Details |
|---|---|---|---|
| **`dev-workflow`** | Code — Ruby on Rails & Python | TDD + a deterministic pre-commit hook (linter/security/branch gate) | [dev-workflow/README.md](./dev-workflow/README.md) |
| **`craft-workflow`** | Non-code — design, content, research | Agent-run sign-off gates + a critique-and-fix review loop (no hook) | [craft-workflow/README.md](./craft-workflow/README.md) |

Both share the same spine: a **domain-agnostic kernel** (dev: `agent_docs/core/coding_workflow.md`, craft: `craft_docs/core/craft_workflow.md`) plus **packs** that supply the concrete tools or rubrics. The kernel names things by *role*; the packs bind them. They don't cross-trigger — install whichever you need, or both.

## The shared method

1. **Discovery → sign-off** — understand audience, goal, and constraints before producing anything.
2. **Plan as a resumable living doc** — atomic pieces, decisions, dead-ends, open questions.
3. **Criteria-first** — define what "good" looks like *before* you produce. In `dev-workflow` that's a failing test; in `craft-workflow` it's an acceptance rubric. Same move.
4. **Produce → check → iterate** — produce a piece, check it against its criteria, fix, present.
5. **Completion review loop** — critique the whole thing against every dimension, report → fix → **re-review** until a round comes back clean.

The difference is only in step-3/5 enforcement: code has deterministic checks (a commit hook), non-code is pure judgment (the review loop carries the whole bar).

## Surviving long sessions

Long sessions degrade agents, so both plugins keep state **outside the conversation**: a per-deliverable living doc (`docs/features/<feature>.md` / `craft/<name>.md`) holds the plan, decisions, dead ends, and a log of every review round — any future session resumes from it instead of re-deriving context. Each plugin also ships a quick-reference floor card (`agent_docs/core/quickref.md` / `craft_docs/core/quickref.md`): the distilled rules to re-read when context is tight. `dev-workflow` adds two active pieces — a **context-guard hook** that warns as auto-compact approaches and re-anchors the agent right after a compaction, and a **`/transfer-context`** command that writes a structured handoff file for continuing in a fresh session.

## Install

```
/plugin marketplace add amiran-levanovich/claude_setup
/plugin install dev-workflow@claude-setup       # code
/plugin install craft-workflow@claude-setup     # design · content · research
```

After installing, run **`workflow-init`** (dev) or just describe a task to trigger **`craft-init`** (craft) — each onboards the project, and reports which advised orchestration skills are available vs. worth installing.

## Repo layout

```
.claude-plugin/
└── marketplace.json     # lists both plugins

dev-workflow/            # code plugin      (source: ./dev-workflow)    → dev-workflow/README.md
craft-workflow/          # non-code plugin  (source: ./craft-workflow)  → craft-workflow/README.md
CLAUDE.md                # maintainer memory for this repo
```

Each plugin is a self-contained directory with the same shape: `.claude-plugin/plugin.json` manifest, `.claude/skills/` routers, and a knowledge base (`agent_docs/` / `craft_docs/`) the skills point into.

## Per-plugin documentation

- **[dev-workflow →](./dev-workflow/README.md)** — language detection, the TDD spine, the pre-commit gate, the Ruby/Python packs, mandatory tooling.
- **[craft-workflow →](./craft-workflow/README.md)** — the non-code method, the experience-design / content / research packs, the orchestration registry and availability check.

## License

[MIT](./LICENSE)
