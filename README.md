# claude_setup

A Claude Code configuration kit for **Ruby on Rails and Python** projects — installable as a **plugin** (`dev-workflow`) or usable as a **drop-in copy**.

Enforces one opinionated development workflow across both languages: structured greenfield setup, a TDD lifecycle, database safety standards, and automated code style. A **language-agnostic spine** (`agent_docs/core/`) drives the process; **per-language packs** (`agent_docs/ruby/`, `agent_docs/python/`) supply the concrete tools. Two layers of enforcement: a shared knowledge base surfaced through auto-triggering skills, and a deterministic pre-commit hook that dispatches on the project's marker file and blocks commits to `main` or with linter/security failures — independent of whether the agent remembers the rules.

| Language | Frameworks | Linter / format | Security | Tests | N+1 / perf |
|---|---|---|---|---|---|
| **Ruby** | Rails | RuboCop (+ rubocop-rails) | Brakeman | RSpec | Bullet |
| **Python** | Django, FastAPI | Ruff (lint + format) | Bandit | pytest | query-count assertions |

---

## What's inside

```
.claude-plugin/
├── plugin.json                   # Plugin manifest (name: dev-workflow)
└── marketplace.json              # Lets this repo serve as its own plugin marketplace

hooks/
└── hooks.json                    # Plugin-mode registration of the pre-commit hook

.claude/
├── agents/
│   ├── rubocop-fixer.md          # Sub-agent: fixes RuboCop offenses rubocop -A can't auto-correct
│   └── ruff-fixer.md             # Sub-agent: fixes Ruff offenses ruff --fix can't auto-correct
├── commands/
│   └── transfer-context.md       # Slash command: compress session into a handoff file for a new chat
├── hooks/
│   └── pre-commit-gate.sh        # Deterministic gate: dispatches on marker file (Ruby vs Python)
├── skills/                       # Thin auto-triggering pointers into agent_docs/ (language-detecting)
│   ├── greenfield-setup/
│   ├── tdd-workflow/
│   ├── schema-migrations/
│   ├── testing/
│   └── workflow-init/            # Onboarding: detect repo state, scan or scaffold, audit tooling
└── settings.json                 # Registers the PreToolUse commit hook

agent_docs/                       # Knowledge base — single source of truth, read before acting
├── core/
│   └── coding_workflow.md        # Language-agnostic TDD lifecycle, Git hygiene, conventional commits
├── ruby/
│   ├── building_the_project.md   # Rails greenfield playbook (Phases 0–4)
│   ├── code_conventions.md       # Ruby/Rails conventions a linter can't check
│   ├── database_schema.md        # ActiveRecord migration safety, indexing (PostgreSQL)
│   ├── running_tests.md          # RSpec hierarchy, FactoryBot, mocking
│   └── toolchain.md              # RuboCop/Brakeman/Bullet/RSpec bindings + gate commands
└── python/
    ├── building_the_project.md   # Python greenfield (Django/FastAPI choice, Phases 0–4)
    ├── code_conventions.md       # Python conventions beyond Ruff
    ├── database_schema.md        # Django ORM / SQLAlchemy+Alembic migration safety (PostgreSQL)
    ├── running_tests.md          # pytest hierarchy, factory_boy, respx/responses mocking
    └── toolchain.md              # Ruff/Bandit/pytest bindings + gate commands

CLAUDE.md                         # Root project instructions for Claude Code
```

---

## How it works

**Language detection.** Every skill and the hook key off the project's marker file: `Gemfile` → Ruby/Rails, `pyproject.toml` / `setup.py` / `setup.cfg` → Python. The spine resolves `<lang>` and routes the concrete commands to that pack's `toolchain.md`.

**`agent_docs/core/coding_workflow.md`** is the language-agnostic spine: branching strategy, Conventional Commits, the feature-doc lifecycle, the TDD cycle (write failing test → commit → implement → pass), and the feature-completion review loop. It names tools only by role — "the linter," "the security scanner" — and defers the concrete commands to `<lang>/toolchain.md`.

**`agent_docs/<lang>/`** packs supply the specifics: conventions a linter can't check, the testing strategy, migration safety, the greenfield playbook, and the role→tool bindings.

**`.claude/skills/`** holds thin skills that auto-surface when the task matches and route to the right doc:

| Skill | Routes to |
|---|---|
| `tdd-workflow` | `core/coding_workflow.md` (+ detected `<lang>/toolchain.md`) |
| `greenfield-setup` | `<lang>/building_the_project.md` |
| `schema-migrations` | `<lang>/database_schema.md` |
| `testing` | `<lang>/running_tests.md` |
| `workflow-init` | onboarding + tooling audit (see below) |

**`.claude/hooks/pre-commit-gate.sh`** is the deterministic enforcement layer. Every `git commit` is intercepted; it dispatches on the marker file and blocks the commit unless the branch is not `main`/`master` and the language's linter (+ formatter, + security scanner when installed) is clean. It deliberately skips the test suite — the TDD cycle commits intentionally failing tests — so the green-suite check stays with the agent.

**`rubocop-fixer` / `ruff-fixer`** are scoped sub-agents invoked after the auto-corrector when residual offenses remain. They fix what the auto-corrector can't, never disable a rule, and flag anything they can't resolve as `UNRESOLVABLE` for human review.

**`/transfer-context`** hands off to a new session when the current one is degraded or hitting context limits — it writes a structured handoff file and gives you one line to paste into the new chat.

### Onboarding: `workflow-init`

Run `workflow-init` right after installing the plugin in a project. It is **state-driven**, not a questionnaire:

- **Existing repo** (marker present) → it scans the stack and pre-fills a project-identity draft from your models/routes/schema, asks you to **confirm or correct** it, then writes a `## Project Identity` section into the project `CLAUDE.md`. No "may I scan?" prompt — scanning is read-only and always wanted.
- **Empty repo** → it routes into greenfield setup: pick the language (Ruby/Rails or Python), then the framework (Python: Django or FastAPI), and hands off to the matching `building_the_project.md`.

Either way it then audits the language's mandatory tooling, hook prerequisites, and CLAUDE.md guidance, and offers to close each gap.

### Per-feature living docs

Each feature in progress gets a context doc at `docs/features/<feature>.md` in the target project — the task checklist, decisions made (and why), failed approaches, and open questions. Any future session resumes from this doc instead of re-deriving context. The folder is bounded by design: when the feature's PR merges, durable decisions are promoted to the project's `CLAUDE.md` and the doc is deleted — git history preserves it.

---

## How to use

### Option A — install as a plugin (recommended)

The repo is a self-hosting Claude Code plugin marketplace. In any Claude Code session:

```
/plugin marketplace add amiran-levanovich/claude_setup
/plugin install dev-workflow@claude-setup
```

Everything ships with the plugin: the skills, the `transfer-context` command, both fixer agents, and the pre-commit hook (registered via `hooks/hooks.json` with `${CLAUDE_PLUGIN_ROOT}`). The skills read `agent_docs/` from inside the plugin, so target projects need no extra files.

After installing, run `workflow-init` in your project — it detects whether the repo is existing or greenfield and takes it from there.

### Option B — drop-in copy

Copy the contents of this repo into the root of your project:

```bash
git clone https://github.com/amiran-levanovich/claude_setup.git
cp -r claude_setup/.claude your-project/
cp -r claude_setup/agent_docs your-project/
cp claude_setup/CLAUDE.md your-project/
```

Then open the project in Claude Code. On session start it reads `CLAUDE.md`, picks up the `agent_docs/` knowledge base, registers the skills (they auto-trigger on matching tasks), and registers the pre-commit hook from `.claude/settings.json`.

> **Hook requirement:** the commit gate parses hook input with `jq`, falling back to `python3` — at least one must be on `PATH`. The gate only activates in projects with a recognized marker file (`Gemfile` or `pyproject.toml`/`setup.py`), so it is inert in non-code repos.

### Customizing per project

The skills look for `agent_docs/` in the **project root first** and only fall back to the plugin's bundled copy. To tailor any playbook to a specific project, copy that one file into the project's `agent_docs/<lang>/` (or `core/`) and edit it there. The project copy wins; the other playbooks keep coming from the plugin.

---

## Workflow summary

1. **New project** → `<lang>/building_the_project.md` (4 phases, sign-off gate before any feature code; Python picks Django/FastAPI in Phase 1)
2. **Daily feature work** → `core/coding_workflow.md` TDD cycle: write failing test → commit → write code → pass
3. **Pre-commit gate** → hook-enforced per language: feature branch + clean linter/format + clean security scan; agent-enforced: N+1 audit + green suite
4. **Commits** → Conventional Commits format (`feat`, `fix`, `test`, `refactor`, …), subject ≤ 60 chars
5. **Feature-completion review** → before the PR: a review → report → fix → re-review **loop** over the full feature diff (style, security, DRY/design, N+1s) that repeats until a round comes back clean
6. **Merge** → pull request into `main` only — direct commits to `main` are blocked by the hook

---

## Recommended: Plannotator plugin

This setup references the **[Plannotator](https://github.com/backnotprop/plannotator)** Claude Code plugin in several places inside both `building_the_project.md` playbooks (requirements review, the optional UX map, the setup roadmap, and the final sign-off presentation). Install it from the Claude Code plugin registry and it will be available as `plannotator`. Without it, those steps fall back to inline markdown documents and task lists — functional but less structured. Plannotator is recommended, not required.

---

## Core mandatory tooling

### Ruby / Rails

| Gem | Purpose | Enforced by |
|---|---|---|
| `bullet ~> 8` | N+1 query detection | Agent — suite run with bullet before implementation commits |
| `brakeman ~> 7` | Static security analysis | Hook — blocks `git commit` on warnings |
| `rubocop ~> 1` | Code style enforcement | Hook — blocks `git commit` on offenses |
| `rubocop-rails ~> 2` | Rails-specific cops | Hook — part of the RuboCop check |
| `strong_migrations ~> 2` | Zero-downtime migration safety | Gem itself — raises on unsafe migrations at runtime |

### Python

| Package | Purpose | Enforced by |
|---|---|---|
| `ruff` | Lint + format (replaces black/flake8/isort) | Hook — blocks `git commit` on offenses or unformatted code |
| `bandit` | Static security analysis | Hook — blocks `git commit` on issues |
| `pytest` (+ `pytest-cov`) | Test runner + coverage | Agent — green suite before implementation commits |
| `factory_boy` + `faker` | Test data factories | Agent |
| `respx` / `responses` | HTTP mocking (total mocking mandate) | Agent |

`mypy` is supported as an **opt-in**, not part of the commit gate — `workflow-init` offers to wire it up. There is no ambient N+1 raiser like Bullet in Python; N+1 protection is assertion-based in the tests (see `python/running_tests.md`).
