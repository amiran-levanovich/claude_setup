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

### The Isolation Mandate: Never Commit Directly to Main
> **Why we never commit to main:** The `main` branch represents stable, production-ready truth. Bypassing pull requests introduces unverified architectural regressions, circumvents automated security pipelines, risks corrupting production states, and degrades code review audit trails. Feature branches keep experimental code safely contained until proven resilient.

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
- Description is lowercase, imperative mood, no trailing period.
- Breaking changes: append `!` after type — e.g. `feat(api)!: rename user endpoint`.

Examples:
```
feat(auth): add JWT token refresh endpoint
test(orders): add failing specs for cancellation flow
fix(payments): handle nil gateway response on timeout
```

---

## PHASE 2: THE STRICT TDD CYCLE
All implementation code must pass through an unyielding Test-Driven Development workflow. Never write production code ahead of its test suite.

[1. Write Test] ──> [2. Verify Failure] ──> [3. Commit Test] ──> [4. Write Code] ──> [5. Commit Pass]

### Step 1: Write Tests First
*   Begin by describing the desired functionality and writing tests for a new feature that does not yet exist.
*   Explicitly state to yourself: *"We are operating under strict TDD rules."* This prevents you from creating mock triumphs or stubbing out imaginary code prematurely.

### Step 2: Confirm Tests Fail
*   Execute the newly written specs immediately using your built-in Bash tool.
*   **Mandatory Check:** Verify that the suite fails, and ensure it fails *for the correct reasons* (e.g., missing method, uninitialized constant), proving the test is accurately targeting the code gap.

### Step 3: Commit Failing Tests
*   Commit the failing test suite to your feature branch. This establishes a clear, verifiable definition of "done" inside the repository history.

### Step 4: Write Code to Pass
*   Write the implementation code with the sole goal of making all the committed tests pass.
*   *Strict Boundary:* You are completely forbidden from altering, modifying, or deleting any lines within the committed test files to force a green light. Refer to `running_tests.md` to ensure correct execution parameters.

### Step 5: Commit Passing Code
*   Once tests pass, clear the **Pre-Commit Verification Gate** (detailed below) and commit the implementation code, completing the atomic TDD loop.

---

## PHASE 3: PRE-COMMIT VERIFICATION GATE
Before a commit can be staged and saved to your feature branch, a local execution sweep must be triggered:

1.  **Memory Audit:** Run your test suite with **`bullet`** enabled to guarantee zero memory leaks or unexpected N+1 queries are introduced.
2.  **Style Cleanup:** Invoke the **`rubocop-fixer`** sub-agent (`.claude/agents/rubocop-fixer`) via the Claude agent system. Pass it the list of changed files. It reads `agent_docs/code_conventions.md` for hard constraints, applies all auto-fixable offenses, and returns a fix report. Any `UNRESOLVABLE` offenses in the report must be addressed manually before committing.
3.  **Result:** The entire pipeline must be 100% green. If any linter, security, or memory audit fails, you are strictly forbidden from committing. Fix the offenses within the boundary of your feature branch before trying again.