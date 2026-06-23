## Project Overview
This is the **dev-workflow** kit: an opinionated, polyglot development workflow for Claude Code covering **Ruby on Rails** and **Python** (Django / FastAPI). A language-agnostic spine drives the lifecycle; per-language packs supply the concrete tooling. All development, refactoring, database design, and testing align with the detected project's ecosystem standards.

## The Agent Knowledge Base (agent_docs/)
A dedicated reference library is maintained at `agent_docs/` in the project root. This path is always relative — the same setup works across any project. It is split into a language-agnostic **core** and per-language packs:

```
agent_docs/
├── core/coding_workflow.md   # the language-agnostic TDD lifecycle + gate (read for every feature)
├── ruby/   {building_the_project, code_conventions, database_schema, running_tests, toolchain}.md
└── python/ {building_the_project, code_conventions, database_schema, running_tests, toolchain}.md
```

**Core Rule**: Memory is volatile; documentation is deterministic. Detect the project language by its marker file (`Gemfile` → `ruby`, `pyproject.toml`/`setup.py` → `python`), then before executing in any of these domains read the corresponding file first:

| Domain | File |
|---|---|
| Writing any feature, bugfix, or refactor (TDD cycle + gate) | `agent_docs/core/coding_workflow.md` (routes to `<lang>/toolchain.md`) |
| Starting a new project or subsystem from scratch | `agent_docs/<lang>/building_the_project.md` |
| Writing or reviewing code | `agent_docs/<lang>/code_conventions.md` |
| Creating migrations or designing schemas | `agent_docs/<lang>/database_schema.md` |
| Writing or running tests | `agent_docs/<lang>/running_tests.md` |
| Concrete tool bindings (linter, scanner, test runner, fixer agent) | `agent_docs/<lang>/toolchain.md` |

The skills in `.claude/skills/` are thin pointers into these same files — whichever route triggers first, the agent_docs file is the single source of truth.

## Enforcement Layers
Prose rules are best-effort; hooks are deterministic. `.claude/settings.json` registers a PreToolUse hook (`.claude/hooks/pre-commit-gate.sh`) that intercepts every `git commit`, dispatches on the project's marker file, and blocks the commit unless:
1. The current branch is not `main`/`master` (all languages).
2. **Ruby:** `bundle exec rubocop` is clean; `bundle exec brakeman` reports no warnings (when installed).
3. **Python:** `ruff check` and `ruff format --check` are clean; `bandit` reports no issues (when installed).

The hook deliberately does not run the test suite — TDD Step 3 commits intentionally failing tests. The green-suite requirement for implementation commits remains your responsibility per `agent_docs/core/coding_workflow.md`.

## Standard Commands & Generator Policy
These are per-language. `workflow-init` writes the matching block into a target project's `CLAUDE.md`; the authoritative reference lives in `agent_docs/<lang>/toolchain.md` and `building_the_project.md`.

### Ruby / Rails
* Setup: `bundle install` · `rails db:create db:migrate db:seed` · reset: `rails db:drop db:create db:migrate db:seed`
* Server: `bin/dev` (Rails 7+) or `bundle exec rails server`
* Tests/lint: `bundle exec rspec` · `bundle exec rubocop` · auto-fix `bundle exec rubocop -A`
* Generators — **use** `rails generate model/migration/controller` (single-concern); **avoid** `rails generate scaffold`; **never** generate specs. Approved-generator scaffolding is exempt from the tests-first gate (the gate applies to behavior). See `core/coding_workflow.md`, Phase 2.

### Python (Django / FastAPI)
* Setup (prefer uv): `uv sync` · DB: Django `manage.py migrate` / Alembic `alembic upgrade head`
* Server: Django `manage.py runserver` · FastAPI `uvicorn app.main:app --reload`
* Tests/lint: `uv run pytest` · `uv run ruff check .` · format `uv run ruff format .` · security `uv run bandit -r .`
* Generators — Django `startapp` / `makemigrations` scaffolding is exempt from the tests-first gate (the gate applies to behavior). See `core/coding_workflow.md`, Phase 2.
