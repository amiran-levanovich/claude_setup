# claude_setup

A drop-in Claude Code configuration kit for Ruby / Ruby on Rails projects.

Enforces an opinionated development workflow: structured greenfield setup, TDD lifecycle, database safety standards, and automated code style. Two layers of enforcement: a shared knowledge base (`agent_docs/`) surfaced through auto-triggering skills, and a deterministic pre-commit hook that blocks commits to `main` and commits with RuboCop or Brakeman failures — independent of whether the agent remembers the rules.

---

## What's inside

```
.claude/
├── agents/
│   └── rubocop-fixer.md          # Sub-agent: fixes RuboCop offenses rubocop -A can't auto-correct
├── commands/
│   └── transfer-context.md       # Slash command: compress session into a handoff file for a new chat
├── hooks/
│   └── pre-commit-gate.sh        # Deterministic gate: blocks commits to main / with rubocop or brakeman failures
├── skills/                       # Thin auto-triggering pointers into agent_docs/
│   ├── rails-greenfield-setup/
│   ├── rails-tdd-workflow/
│   ├── rails-db-migrations/
│   └── rails-testing/
└── settings.json                 # Registers the PreToolUse commit hook

agent_docs/                       # Knowledge base — single source of truth, read before acting
├── building_the_project.md       # 4-phase greenfield initialization playbook
├── code_conventions.md           # Ruby/Rails conventions a linter can't check
├── coding_workflow.md            # Daily TDD lifecycle, Git hygiene, conventional commits
├── database_schema.md            # DB design, migration safety, indexing standards (PostgreSQL)
└── running_tests.md              # Testing hierarchy, FactoryBot strategy, RSpec execution

CLAUDE.md                         # Root project instructions for Claude Code
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

Then open the project in Claude Code. On session start it automatically:

- reads `CLAUDE.md` and picks up the `agent_docs/` knowledge base,
- registers the skills from `.claude/skills/` (they auto-trigger on matching tasks),
- registers the pre-commit hook from `.claude/settings.json`.

> **Hook requirement:** the commit gate parses hook input with `jq`, falling back to `python3` — at least one must be on `PATH` (virtually always true; without both, the gate degrades to substring matching). The gate only activates in projects with a `Gemfile`, so it is inert in non-Ruby repos.

---

## How it works

**`CLAUDE.md`** tells Claude this is a Ruby/Rails workspace and establishes one core rule:

> Memory is volatile; documentation is deterministic. Read the relevant `agent_docs/` file before acting.

**`agent_docs/`** is a reference library Claude consults before each domain-specific task:

| File | When Claude reads it |
|---|---|
| `building_the_project.md` | Starting a new project from scratch |
| `coding_workflow.md` | Writing any feature (TDD cycle + pre-commit gate) |
| `code_conventions.md` | Writing or reviewing Ruby/Rails code (only conventions a linter can't check) |
| `database_schema.md` | Creating migrations or designing schemas |
| `running_tests.md` | Running or writing specs |

**`.claude/skills/`** holds thin skills that auto-surface when the task matches (migrations, testing, TDD, greenfield setup) and point Claude at the corresponding `agent_docs/` file. The docs stay the single source of truth; the skills just make triggering automatic instead of relying on Claude remembering the CLAUDE.md rule.

**`.claude/hooks/pre-commit-gate.sh`** is the deterministic enforcement layer, registered as a PreToolUse hook in `.claude/settings.json`. Every `git commit` in a Rails project (Gemfile present) is blocked unless the branch is not `main`/`master`, `rubocop` is clean, and `brakeman` reports no warnings. It deliberately skips the spec suite — the TDD cycle commits intentionally failing tests — so the green-suite check stays with the agent.

**`rubocop-fixer`** is a scoped sub-agent invoked after `rubocop -A` when residual offenses remain. It fixes what the auto-corrector can't, never disables cops, and flags anything it can't resolve as `UNRESOLVABLE` for human review.

**`/transfer-context`** is a slash command for handing off to a new session when the current one is degraded or hitting context limits. It writes a structured handoff file to `.claude/context-transfers/` and gives you a single line to paste into the new chat — decisions made, traps to avoid, relevant file locations, and open work described as status (not instructions).

---

## Workflow summary

1. **New project** → follow `building_the_project.md` (4 phases, sign-off gate before any feature code)
2. **Daily feature work** → `coding_workflow.md` TDD cycle: write failing test → commit → write code → pass
3. **Pre-commit gate** → hook-enforced: feature branch + clean RuboCop + clean Brakeman; agent-enforced: Bullet N+1 audit + green suite
4. **Commits** → Conventional Commits format (`feat`, `fix`, `test`, `refactor`, …), subject ≤ 60 chars
5. **Merge** → pull request into `main` only — direct commits to `main` are blocked by the hook

---

## Recommended: Plannotator plugin

This setup references the **[Plannotator](https://github.com/backnotprop/plannotator)** Claude Code plugin in three places inside `building_the_project.md`:

- **Phase 0** — the requirements document (`docs/requirements.md`) is annotated via Plannotator before user sign-off.
- **Phase 2** — the full project setup roadmap is decomposed into isolated sub-tasks and reviewed via Plannotator before any code is written.
- **Phase 4** — the architectural diagrams, schema maps, and task roadmaps are compiled into a final presentation via Plannotator for user sign-off.

Install it from the Claude Code plugin registry and it will be available as `plannotator` in your Claude Code sessions. Without it, those steps fall back to inline markdown documents and task lists — functional but less structured. Plannotator is recommended, not required: the workflow has no hard dependency on it.

---

## Core mandatory tooling

Every project initialized with this setup ships with:

| Gem | Purpose | Enforced by |
|---|---|---|
| `bullet ~> 8` | N+1 query detection | Agent — test suite run with bullet enabled before implementation commits |
| `brakeman ~> 7` | Static security analysis | Hook — blocks `git commit` on warnings |
| `rubocop ~> 1` | Code style enforcement | Hook — blocks `git commit` on offenses |
| `rubocop-rails ~> 2` | Rails-specific cops | Hook — runs as part of the RuboCop check |
| `strong_migrations ~> 2` | Zero-downtime migration safety | Gem itself — raises on unsafe migrations at runtime |
