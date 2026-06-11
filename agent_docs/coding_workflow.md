# Daily Feature Engineering & TDD Lifecycle

This runbook dictates the mandatory day-to-day workflow for writing, testing, linting, and committing features. It interfaces directly with your other workspace blueprints.

---

## WORKSPACE CROSS-REFERENCES
When executing changes under this playbook, dynamically reference the sibling documentation in `agent_docs/` as needs arise:
*   Refer to `code_conventions.md` for formatting, layout, styling, and structural syntax rules.
*   Refer to `running_tests.md` for specific test suite engine configurations and execution flags.
*   Refer to `database_schema.md` for custom conventions regarding indexes, queries, and migrations.

---

## PHASE 1: BRANCHING STRATEGY & GIT HYGIENE
Coding is strictly isolated into short-lived, single-purpose feature branches.

### Never Commit Directly to Main
> **Why:** The `main` branch represents stable, production-ready truth. Bypassing pull requests introduces unverified regressions, circumvents automated security pipelines, and degrades code review audit trails. Feature branches keep experimental code safely contained until proven resilient.
>
> This rule is enforced deterministically: the pre-commit hook (`.claude/hooks/pre-commit-gate.sh`) blocks any `git commit` on `main`/`master` in a Rails project.

### Branch Naming & Merge Flow
*   Branch from an up-to-date `main`: `git checkout -b <type>/<short-kebab-description>` — e.g. `feature/order-cancellation`, `fix/nil-gateway-timeout`, `refactor/extract-payment-service`.
*   Keep branches single-purpose and short-lived (days, not weeks). Rebase on `main` if it drifts.
*   Merge back via pull request only. Never merge locally into `main`. Open the PR when the feature's full TDD loop is complete and the suite is green.

### Commit Message Format: Conventional Commits
All commit messages must follow the [Conventional Commits](https://www.conventionalcommits.org) specification.

Format: `<type>(<scope>): <description>`

| Type | When to use |
| :--- | :--- |
| `feat` | New feature or behaviour |
| `fix` | Bug fix |
| `test` | Adding or updating specs (use for TDD Step 3 — failing tests commit) |
| `refactor` | Code restructure with no behaviour change |
| `chore` | Dependency updates, config, tooling |
| `docs` | Documentation only |
| `perf` | Performance improvement |

Rules:
- **Subject line must not exceed 60 characters** (type + scope + description combined). This is a hard limit — reword until it fits.
- Description is lowercase, imperative mood, no trailing period.
- Breaking changes: append `!` after type — e.g. `feat(api)!: rename user endpoint`.

Examples:
```
feat(auth): add JWT token refresh endpoint
test(orders): add failing specs for cancellation flow
fix(payments): handle nil gateway response on timeout
```

---

## PHASE 2: THE TDD CYCLE
All implementation code passes through Test-Driven Development. The hard rule of this phase:

> ❌ **Tests come first.** Do not write implementation code before the corresponding spec exists and has been committed. If you find yourself opening an implementation file before its spec file, stop and return to Step 1.
>
> **Exemption — framework scaffolding:** files produced by the approved Rails generators (`rails generate model/migration/controller` — see the CLAUDE.md generator policy) do not count as implementation code. The gate applies to behavior: methods, scopes, queries, validations, business logic.

### Feature Planning Gate (mandatory before every feature)
Before the TDD loop begins for any feature, you must produce a **feature-scoped to-do list**. This is separate from the project-level to-do list produced in Phase 2 of `building_the_project.md`.

Decompose the feature into its atomic implementation tasks and write them as a checklist. A task is atomic when it maps to a single spec and a single production change. Example format:

```
## Feature: <name>
- [ ] spec: <what the test covers>
- [ ] impl: <what the implementation does>
- [ ] spec: ...
- [ ] impl: ...
```

Present this list to the user and receive acknowledgement before proceeding. Mark each item completed as you progress — do not advance to the next item until the current TDD loop (Steps 1–5) is complete.

When presenting the list, also ask the user to choose a **review pacing**:

1. **Per-cycle review** (default) — pause after each completed TDD loop for user review before starting the next item.
2. **Autonomous** — work through the whole checklist and present the completed feature at the end. Even in this mode, pause immediately if a task requires significant deviation from the approved list (a new dependency, a schema change not on the list, a changed public interface).

Default to per-cycle review if the user expresses no preference.

[1. Write Test] ──> [2. Verify Failure] ──> [3. Commit Test] ──> [4. Write Code] ──> [5. Commit Pass]

### Step 1: Write Tests First
*   Begin by describing the desired functionality and writing tests for a new feature that does not yet exist.
*   Create and save the spec file before any implementation file is touched — this is the entry gate to the cycle.

### Step 2: Confirm Tests Fail
*   Execute the newly written specs immediately using your built-in Bash tool.
*   **Mandatory Check:** Verify that the suite fails, and ensure it fails *for the correct reasons* (e.g., missing method, uninitialized constant), proving the test is accurately targeting the code gap.

### Step 3: Commit Failing Tests
*   Commit the failing test suite to your feature branch. This establishes a clear, verifiable definition of "done" inside the repository history.

### Step 4: Write Code to Pass
*   Write the implementation code with the sole goal of making all the committed tests pass.
*   ❌ **Never alter, weaken, or delete committed test files to force a green light.** This is an absolute rule with no exceptions. If a committed test turns out to be genuinely wrong, stop and raise it with the user instead. Refer to `running_tests.md` for correct execution parameters.

### Step 5: Commit Passing Code
*   Once tests pass, clear the **Pre-Commit Verification Gate** (detailed below) and commit the implementation code, completing the atomic TDD loop.

### Pre-Present Verification (every TDD loop)
Before presenting code from Step 1 or Step 4 to the user, verify it — generate first, then check, then present:

*   If the loop touched a **migration** — run the Self-Validation Checklist in `database_schema.md`.
*   If the loop wrote or changed **specs** — run the Self-Validation Checklist in `running_tests.md`.
*   Check the conventions in `code_conventions.md` that RuboCop can't enforce (predicate naming, magic-value constants, memoization safety).

Fix violations before presenting — never present code you know fails a checklist. When everything passes, a one-line compliance note is enough; be verbose only when reporting violations and their fixes. If a checklist surfaces a genuine judgment call, present the options with trade-offs instead of silently choosing.

---

## PHASE 3: PRE-COMMIT VERIFICATION GATE
The gate has two layers — one enforced by the harness, one that remains your responsibility.

### Enforced automatically (PreToolUse hook)
`.claude/hooks/pre-commit-gate.sh` intercepts every `git commit` in a Rails project (Gemfile present) and blocks it unless:

1.  The current branch is not `main`/`master`.
2.  `bundle exec rubocop` is clean.
3.  `bundle exec brakeman` reports no security warnings (when the gem is installed).

The hook does **not** run the spec suite, because TDD Step 3 commits intentionally failing tests.

### Your responsibility before an implementation commit (Step 5)
1.  **N+1 Query Audit:** Run the test suite with **`bullet`** enabled to catch N+1 queries and unused eager loading introduced by the change.
2.  **Style Cleanup:** Run `bundle exec rubocop -A`. If residual offenses remain, invoke the **`rubocop-fixer`** sub-agent (`.claude/agents/rubocop-fixer.md`) with the list of changed files. Any `UNRESOLVABLE` offenses in its report require human review before committing.
3.  **Green Suite:** The full suite passes. If any check fails, fix it on the feature branch before committing again.