---
name: workflow-init
description: Onboarding and setup audit for the dev-workflow kit in the current project. Use right after installing the plugin, or when the user says 'workflow init', 'set up the workflow', 'onboard this project', 'check the setup', or 'is the tooling installed'. Detects whether the repo is existing or greenfield, scans an existing repo's stack to populate project knowledge (with confirmation), or routes a new repo into greenfield setup. Then audits the language's mandatory tooling, hook prerequisites, and CLAUDE.md guidance, and offers to close each gap.
---

# Workflow Init

The single entry point for getting a project ready for this workflow. **Do not change any files without explicit approval** — detect, report, then apply only what the user confirms.

## Step 1 — Detect repo state (state drives the path, not a prompt)

Look for a language marker file in the project root:

- `Gemfile` → **ruby** (Rails)
- `pyproject.toml` / `setup.py` / `setup.cfg` → **python**

Decide the path from what you find — **don't ask "should I scan?"** (scanning is read-only and always wanted for an existing repo):

- **Marker present** → the repo is an **existing project**. Go to Step 2A.
- **No marker / empty repo** → **greenfield**. Go to Step 2B.
- **Both markers** (polyglot monorepo) → ask the user which subtree/language to onboard, then proceed as 2A for it.

## Step 2A — Existing project: scan, confirm, populate

1. **Scan the stack** (read-only): language (marker), framework (Rails via the `rails` gem; Django via the `django` dep; FastAPI via the `fastapi` dep), key libraries, test runner, and database. For Python, also detect the dependency manager (`uv.lock` / `poetry.lock` / `requirements*.txt`).
2. **Pre-fill project identity from the code** — scan models/routes/schema (Ruby: `app/models`, `config/routes.rb`, `db/schema.rb`; Python: models modules, routers/urls, migrations) and draft: what the app does, its 3–5 core models and how they relate, domain terms, and conventions not visible in code.
3. **Present a detected-stack summary + the drafted identity, and ask the user to confirm or correct it** (AskUserQuestion, with concrete options derived from the scan; free-text only for the domain description). Correction here is also the escape hatch for "detection is wrong / I want to redefine."
4. **On confirmation, write** a `## Project Identity` section into the project `CLAUDE.md` (create the file if absent). Keep it under ~30 lines — `CLAUDE.md` loads into every session; summarize, don't transcribe.

Then run **Step 3** (tooling audit) for the detected language.

## Step 2B — Greenfield: choose, then build

The repo has no code yet, so there is nothing to scan. Route into greenfield setup:

1. Ask the user which language to scaffold — **Ruby/Rails** or **Python** (AskUserQuestion).
2. For Python, ask the framework — **Django** or **FastAPI**.
3. Hand off to the `greenfield-setup` skill / the matching `agent_docs/<lang>/building_the_project.md`, which runs Phases G0–G4 and the sign-off gate. The tooling audit (Step 3) is satisfied as part of Phase G3 there.

## Step 3 — Tooling audit (existing projects)

Present a short status table — one row per check: name, status (ok / missing / warning), proposed action. Then apply only approved fixes and re-verify.

### Ruby / Rails
1. **Mandatory gems** — `bullet` (~> 8), `brakeman` (~> 7, `require: false`), `rubocop` (~> 1, `require: false`), `rubocop-rails` (~> 2, `require: false`), `strong_migrations` (~> 2). Offer to add missing ones and run `bundle install`.
2. **Bullet config** — `Bullet.enable` in `config/environments/development.rb` and `test.rb`; `Bullet.raise = true` in test so N+1s fail the suite.
3. **RuboCop config** — `.rubocop.yml` exists, requires `rubocop-rails`, `NewCops: enable`.
4. See `agent_docs/ruby/toolchain.md` for the authoritative tool list.

### Python
1. **Mandatory dev deps** (in the `dev`/`test` group of `pyproject.toml`) — `ruff`, `bandit`, `pytest`, `pytest-cov`; framework integration (`pytest-django` or `httpx`); `factory_boy` + `faker`; HTTP mocking (`respx`/`responses`). Offer to add missing ones and sync via the detected manager (`uv sync` / `poetry install` / `pip install`).
2. **Ruff config** — a `[tool.ruff]` section in `pyproject.toml` (or `ruff.toml`); confirm both lint and format are configured.
3. **Bandit config** — excludes for the test dir in `[tool.bandit]` so test fixtures don't trip it.
4. **mypy (optional)** — offer to wire it up as an opt-in; it is **not** part of the commit gate.
5. See `agent_docs/python/toolchain.md` for the authoritative tool list.

### Both languages
6. **Hook prerequisites** — verify `jq` or `python3` is on `PATH` (the pre-commit gate needs one for reliable JSON parsing). Warn if neither is available.
7. **CLAUDE.md standard commands** — if the project `CLAUDE.md` lacks the stack's standard commands and generator policy, offer to add an inline section for the detected language (env setup, server, test/lint commands, generator policy). Generate it for the detected stack rather than fetching a fixed template.
8. **Project overrides** — if the project root has an `agent_docs/` directory, list which playbooks it overrides (project copies take precedence over the plugin's). Informational.
9. **Conventions tailoring (optional)** — if no project override of `<lang>/code_conventions.md` exists, offer to create one through a short interview (AskUserQuestion, one topic at a time): naming preferences, error-handling idioms, size thresholds for extracting services, patterns the team mandates or bans. On acceptance, copy the pack's `code_conventions.md` into the project's `agent_docs/<lang>/` and append a `## Project-specific conventions` section with the confirmed answers — the copy wins over the plugin's, and nothing from the base playbook is lost. Skip silently if the user declines; the pack defaults are always sufficient.
10. **In-flight features** — if `docs/features/` exists, list its docs (each a resumable in-flight feature). Informational.
11. **Project lessons** — if `docs/lessons.md` exists, note its entry count and remind that the Feature Planning Gate loads it. Informational.
12. **Review & orchestration tools** — read `agent_docs/core/orchestration.md` (project root first, else `../../../agent_docs/core/orchestration.md` relative to this skill) and run its availability check: inspect the skills/tools available to you this session and report which *advised* tools are present vs missing, with the one-line rationale and install pointer for any absent ("for correct work and best results, these are recommended — and why"). Informational, never blocks — every role has a manual fallback.

## Output
After applying approved fixes, re-verify: the dependency install succeeds, and the linter runs (`bundle exec rubocop --version` / `ruff --version`).
