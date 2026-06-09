# claude_setup

A drop-in Claude Code configuration kit for Ruby / Ruby on Rails projects.

Enforces a strict, opinionated development workflow: structured greenfield setup, TDD lifecycle, database safety standards, and automated code style — all driven by Claude agents reading a shared knowledge base.

---

## What's inside

```
.claude/
├── agents/
│   └── rubocop-fixer.md      # Sub-agent: fixes RuboCop offenses rubocop -A can't auto-correct
└── commands/
    └── transfer-context.md   # Slash command: compress session into a handoff file for a new chat

agent_docs/                   # Knowledge base — agents read these before acting
├── building_the_project.md   # 4-phase greenfield initialization playbook
├── code_conventions.md       # Ruby/Rails style constraints
├── coding_workflow.md        # Daily TDD lifecycle, Git hygiene, conventional commits
├── database_schema.md        # DB design, migration safety, indexing standards (PostgreSQL)
└── running_tests.md          # Testing hierarchy, FactoryBot strategy, RSpec execution

CLAUDE.md                     # Root project instructions for Claude Code
```

---

## How to use

Copy the contents of this repo into the root of your Rails project:

```bash
git clone https://github.com/amiran-levanovich/claude_setup.git
cp -r claude_setup/.claude your-project/
cp -r claude_setup/agent_docs your-project/
cp claude_setup/CLAUDE.md your-project/
```

Then open the project in Claude Code — it will automatically read `CLAUDE.md` and pick up the knowledge base.

---

## How it works

**`CLAUDE.md`** tells Claude this is a Ruby/Rails workspace and establishes one core rule:

> Memory is volatile; documentation is deterministic. Read the relevant `agent_docs/` file before acting.

**`agent_docs/`** is a reference library Claude consults before each domain-specific task:

| File | When Claude reads it |
|---|---|
| `building_the_project.md` | Starting a new project from scratch |
| `coding_workflow.md` | Writing any feature (TDD cycle + pre-commit gate) |
| `code_conventions.md` | Writing or reviewing Ruby/Rails code |
| `database_schema.md` | Creating migrations or designing schemas |
| `running_tests.md` | Running or writing specs |

**`rubocop-fixer`** is a scoped sub-agent invoked after `rubocop -A` when residual offenses remain. It fixes what the auto-corrector can't, never disables cops, and flags anything it can't resolve as `UNRESOLVABLE` for human review.

**`/transfer-context`** is a slash command for handing off to a new session when the current one is degraded or hitting context limits. It writes a structured handoff file to `.claude/context-transfers/` and gives you a single line to paste into the new chat — decisions made, traps to avoid, relevant file locations, and open work described as status (not instructions).

---

## Workflow summary

1. **New project** → follow `building_the_project.md` (4 phases, sign-off gate before any feature code)
2. **Daily feature work** → `coding_workflow.md` TDD cycle: write failing test → commit → write code → pass
3. **Pre-commit gate** → run Bullet (N+1 check) + invoke `rubocop-fixer` + confirm green suite
4. **Commits** → Conventional Commits format (`feat`, `fix`, `test`, `refactor`, …)

---

## Recommended: Plannotator plugin

This setup references the **[Plannotator](https://github.com/backnotprop/plannotator)** Claude Code plugin in three places inside `building_the_project.md`:

- **Phase 0** — the requirements document (`docs/requirements.md`) is annotated via Plannotator before user sign-off. **Mandatory when installed** — skipping it is a workflow violation.
- **Phase 2** — the full project setup roadmap is decomposed into isolated sub-tasks using Plannotator before any code is written.
- **Phase 4** — the architectural diagrams, schema maps, and task roadmaps are compiled into a final presentation via Plannotator for user sign-off.

Install it from the Claude Code plugin registry and it will be available as `plannotator` in your Claude Code sessions. Without it, those two steps fall back to inline markdown task lists — functional but less structured.

---

## Core mandatory tooling

Every project initialized with this setup ships with:

| Gem | Purpose |
|---|---|
| `bullet ~> 8` | N+1 query detection |
| `brakeman ~> 7` | Static security analysis |
| `rubocop ~> 1` | Code style enforcement |
| `rubocop-rails ~> 2` | Rails-specific cops |
| `strong_migrations ~> 2` | Zero-downtime migration safety |
