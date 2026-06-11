---
name: rails-workflow-init
description: Guided setup audit for the rails-workflow kit in the current project. Use right after installing the plugin in a project, or when the user says 'rails-workflow init', 'set up the workflow', 'check the setup', or 'is the tooling installed'. Verifies mandatory gems, RuboCop config, hook prerequisites, and CLAUDE.md guidance, then offers to close each gap.
---

# Rails Workflow Init

Audit the current project's readiness for this workflow, report all findings first, then apply only the fixes the user approves. Never change files without approval.

## Checks

1. **Rails project** — confirm a `Gemfile` exists in the project root. If not, stop: report that this isn't a Ruby project and that the pre-commit gate stays inert here.
2. **Mandatory gems** — check the Gemfile for each of: `bullet` (~> 8, group development/test), `brakeman` (~> 7, group development, `require: false`), `rubocop` (~> 1, group development, `require: false`), `rubocop-rails` (~> 2, group development, `require: false`), `strong_migrations` (~> 2). Offer to add missing ones and run `bundle install`.
3. **Bullet configuration** — `bullet` only works when enabled: check `config/environments/development.rb` and `config/environments/test.rb` for `Bullet.enable`. In test, `Bullet.raise = true` is required so N+1 regressions fail the suite. Offer to add the missing blocks.
4. **RuboCop config** — check `.rubocop.yml` exists. If missing, offer a minimal starter that requires `rubocop-rails` and sets `NewCops: enable`.
5. **Hook prerequisites** — verify `jq` or `python3` is on `PATH` (the pre-commit gate needs one of them for reliable parsing). Warn if neither is available.
6. **CLAUDE.md guidance** (plugin installs only) — if the project root has no `CLAUDE.md` covering the standard Rails commands and generator policy, offer to fetch it:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/amiran-levanovich/claude_setup/main/CLAUDE.md -o CLAUDE.md
   ```
7. **Project overrides** — if the project root contains an `agent_docs/` directory, list which playbooks it overrides (project copies take precedence over the plugin's). Purely informational.
8. **Project identity in CLAUDE.md** — if `CLAUDE.md` exists but contains no project-specific identity (what the app does, its business domain, key models/aggregates, domain vocabulary), offer a short interview — at most six questions: What does the app do and for whom? What are the 3–5 core models and how do they relate? Any domain terms with precise meanings? Any conventions or constraints not visible in the code? — then append the answers as a `## Project Identity` section. This primes every future session with what the project actually is instead of generic Rails assumptions.
9. **In-flight features** — if `docs/features/` exists, list its docs (each is a feature currently in progress, resumable via the TDD workflow). Purely informational.

## Output

Present a short status table — one row per check: check name, status (ok / missing / warning), proposed action. Then ask which fixes to apply, apply the approved ones, and re-verify (`bundle install` succeeds, `bundle exec rubocop --version` runs).
