## Project Overview
This workspace handles Ruby and Ruby on Rails applications. All development, refactoring, database design, and testing protocols must align with the local ecosystem standards.

## The Agent Knowledge Base (agent_docs/)
A dedicated reference library is maintained at `agent_docs/` in the project root. This path is always relative — the same setup works across any project.

**Core Rule**: Memory is volatile; documentation is deterministic. Before executing in any of these domains, read the corresponding file first:

| File | Read it when |
|---|---|
| `agent_docs/building_the_project.md` | Starting a new project or subsystem from scratch |
| `agent_docs/coding_workflow.md` | Writing any feature, bugfix, or refactor (TDD cycle + pre-commit gate) |
| `agent_docs/code_conventions.md` | Writing or reviewing Ruby/Rails code |
| `agent_docs/database_schema.md` | Creating migrations or designing schemas |
| `agent_docs/running_tests.md` | Writing or running specs |

The skills in `.claude/skills/` are thin pointers into these same files — whichever route triggers first, the agent_docs file is the single source of truth.

## Enforcement Layers
Prose rules are best-effort; hooks are deterministic. `.claude/settings.json` registers a PreToolUse hook (`.claude/hooks/pre-commit-gate.sh`) that intercepts every `git commit` in a Rails project (Gemfile present) and blocks it unless:
1. The current branch is not `main`/`master`.
2. `bundle exec rubocop` is clean.
3. `bundle exec brakeman` reports no warnings (when installed).

The hook deliberately does not run the spec suite — TDD Step 3 commits intentionally failing tests. The green-suite requirement for implementation commits remains your responsibility per `agent_docs/coding_workflow.md`.

## Standard Commands
### 1. Environment Setup
* Install dependencies: `bundle install`
* Create and migrate database: `rails db:create db:migrate`
* Seed database: `rails db:seed`
* Reset database: `rails db:drop db:create db:migrate db:seed`

### 2. Development Server
* Start all processes (Rails 7+): `bin/dev`
* Rails server only: `bundle exec rails server`

### 3. Verification & Testing
* Run Entire Suite: `bundle exec rspec`
* Run Single Spec: `bundle exec rspec spec/path/to/file_spec.rb`
* Run Linter (RuboCop): `bundle exec rubocop`
* Auto-Correct Style: `bundle exec rubocop -A`

### 4. Rails Generators — Usage Policy
* **Use:** `rails generate model`, `rails generate migration`, `rails generate controller` — single-concern, explicit.
* **Avoid:** `rails generate scaffold` — generates views, helpers, and assets that pollute the codebase when TDD is active.
* **Never** generate specs via generators; write them manually per `agent_docs/coding_workflow.md`.
* **TDD interaction:** files produced by the approved generators (model/migration/controller scaffolding) are exempt from the tests-first gate — the gate applies to behavior (methods, queries, validations, business logic). See `agent_docs/coding_workflow.md`, Phase 2.