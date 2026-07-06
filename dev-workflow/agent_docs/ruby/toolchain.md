# Ruby / Rails Toolchain Bindings

This file is the single place that maps the **roles** referenced by `core/coding_workflow.md` to the concrete tools used in a Ruby/Rails project. When the spine says "the linter" or "the security scanner," it means the tool named here.

> **Framework:** this pack targets **Ruby on Rails**. Where a binding is Rails-specific (ActiveRecord, `rubocop-rails`, Bullet), it is noted — a non-Rails Ruby project may not have it.

## Role → tool map

| Role (in the spine) | Tool | Invocation |
| :--- | :--- | :--- |
| Dependency manager | **Bundler** | `bundle install`, `bundle exec <cmd>` |
| Linter + formatter | **RuboCop** (+ `rubocop-rails`) | `bundle exec rubocop` · auto-fix: `bundle exec rubocop -A` |
| Security scanner | **Brakeman** | `bundle exec brakeman --quiet --no-pager` |
| N+1 / performance detector | **Bullet** | test suite run with `Bullet.raise = true` in the test env |
| Test runner | **RSpec** | `bundle exec rspec` (see `running_tests.md`) |
| Fixer sub-agent | **`rubocop-fixer`** | invoke after `rubocop -A` leaves residual offenses |
| Review sub-agent | **`diff-reviewer`** | Phase 4 (no review skill installed): dimension `all` in one invocation for small diffs and confirmation passes; one invocation per dimension for large diffs |
| Migration safety | **strong_migrations** | raises on unsafe migrations at runtime (see `database_schema.md`) |

RuboCop fills **both** the linter and formatter roles — there is no separate formatter check in Ruby, so the spine's "formatter check, where the toolchain defines one" is a no-op here.

## Mandatory gems

Every Rails project initialized with this workflow ships with:

| Gem | Pin | Role |
| :--- | :--- | :--- |
| `bullet` | `~> 8` | N+1 query detection |
| `brakeman` | `~> 7` | Static security analysis |
| `rubocop` | `~> 1` | Style enforcement |
| `rubocop-rails` | `~> 2` | Rails-specific cops |
| `strong_migrations` | `~> 2` | Zero-downtime migration safety |

Pins use pessimistic `~>` on the current major. Run `bundle outdated` at init to confirm they are still the latest majors.

## Pre-commit gate (what the hook runs)

In a Ruby project (`Gemfile` present) the hook blocks `git commit` unless:

1. The branch is not `main`/`master`.
2. `bundle exec rubocop --parallel --force-exclusion <changed files>` is clean.
3. `bundle exec brakeman --only-files <changed files>` reports no warnings (when the gem is installed).

Checks are scoped to the Ruby files the commit touches (staged + unstaged vs `HEAD`) — pre-existing offenses elsewhere never block a commit. A commit touching no Ruby files skips the tool runs entirely. The full-app Brakeman scan runs in the Phase 4 review instead, where cross-file flows are back in scope.

The hook deliberately does **not** run RSpec — TDD Step 3 commits intentionally failing tests.

## Before an implementation commit (agent responsibility)

1. **N+1 audit:** run the suite with Bullet enabled (`Bullet.raise = true`) so N+1s and unused eager loads fail the run.
2. **Style cleanup:** `bundle exec rubocop -A`, then the `rubocop-fixer` agent for residual offenses. `UNRESOLVABLE` items need human review.
3. **Green suite:** `bundle exec rspec` passes.
