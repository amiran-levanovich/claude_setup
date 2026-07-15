# dev-workflow — agent instructions (canonical, all harnesses)

This file is the harness-neutral entry point for the **dev-workflow** kit: an opinionated TDD workflow for Ruby/Rails and Python (Django/FastAPI). It is read by OpenAI Codex, Gemini CLI (via `GEMINI.md`), and any other agent that honors `AGENTS.md`. Claude Code users don't need it — install the kit as a plugin instead (see [README.md](./README.md)); the plugin wires everything natively.

The method lives in `agent_docs/`, not here. This file only tells your harness where the method is and how the kit's Claude-specific machinery maps onto yours.

## Session rules

1. **Before the first code change**, read `agent_docs/core/coding_workflow.md` — the kernel: branching, the TDD cycle, the pre-commit gate, the feature-completion review loop. When context is tight or you're resuming lost work, read `agent_docs/core/quickref.md` (the 11-rule floor with a "when lost" protocol) instead of guessing.
2. **Language by marker file in the project root** (one check, never a recursive search): `Gemfile` → ruby, `pyproject.toml`/`setup.py`/`setup.cfg` → python. Every concrete command comes from `agent_docs/<lang>/toolchain.md`.
3. **Path resolution**: if the project root has its own `agent_docs/` directory, those copies win; otherwise use the kit checkout's `dev-workflow/agent_docs/`. Those two locations are the only ones — a doc missing from both is a broken install to report, not a reason to search the filesystem.
4. **Resume, don't re-plan**: `docs/features/<feature>.md` in the project is the living state of an in-flight feature. If it exists, continue from it, honoring every logged decision.

## Skills

The five skills under `.agents/skills/` (symlinks into `.claude/skills/` — one source, two discovery paths) follow the open [Agent Skills](https://agentskills.io) standard:

| Skill               | When it activates                                                     |
| :------------------- | :--------------------------------------------------------------------- |
| `workflow-init`     | Onboarding a project onto the kit; auditing the mandatory tooling     |
| `tdd-workflow`      | Any feature, bugfix, or refactor — the main loop                      |
| `greenfield-setup`  | A brand-new project from scratch                                      |
| `schema-migrations` | Creating/editing migrations, schema design, associations              |
| `testing`           | Writing or speeding up tests (RSpec / pytest)                         |

Codex scans `.agents/skills/` at the repo root and `~/.agents/skills`; Gemini CLI reads `.agents/skills/` as an alias of `.gemini/skills/`. Install wiring: README, "How to use". Each skill is a thin router into `agent_docs/` — the docs are authoritative.

## Capability map — what to do where the docs name a Claude-specific tool

The full table with rationale is in `agent_docs/core/orchestration.md` ("Harness capability fallbacks"). The short form:

- **Commit gate**: run `workflow-init` once — it installs the gate as a plain git pre-commit hook (`pre-commit-gate.sh --git-hook`). The gate is part of the method; don't work without it.
- **Sub-agents** (`diff-reviewer`, `rubocop-fixer`, `ruff-fixer` under `.claude/agents/`): self-contained prompt files. Run them in a second CLI instance for fresh eyes, or follow them inline as a strict protocol and note the weaker isolation in the Review log.
- **`AskUserQuestion`**: present numbered options in chat and stop for the user's pick — the rule is "never decide a judgment call silently".

## Hard floor (even before you've read anything else)

Never commit to `main`. No implementation code before its failing spec exists and is committed. Never weaken or delete a committed spec. Conventional Commits, subject ≤ 60 characters. Act on checked state, not claims.
