# Daily Feature Engineering & TDD Lifecycle

This runbook dictates the mandatory day-to-day workflow for writing, testing, linting, and committing features. It is **language-agnostic** — the concrete tools (linter, security scanner, test runner, N+1/perf check, fixer agent) are defined per language in the matching toolchain doc.

> **Context tight or lost?** `core/quickref.md` is the distilled 10-rule floor with a "when lost" protocol — re-read it instead of guessing.

## EXECUTION TIMELINE

The phases below are **thematic groupings, not a chronology**. What actually runs, in order:

```
P1 branch → P2 planning gate → ⟳ TDD cycle (P2 Steps 1–5; the P3 gate fires on every commit)
          → P4 review loop (until a logged clean round) → PR → merge → P1 feature-doc close-out
```

- **Phase 3 is not a stage after Phase 2** — its hook half intercepts *every* `git commit`, and its agent half runs before every implementation commit (Step 5). It never runs "once".
- **Phase 1's close-out section runs after the PR merges** — the last act of a feature, not the first.
- **Greenfield projects use a separate sequence, Phases G0–G4**, in `<lang>/building_the_project.md`. A bare "Phase N" always refers to this document; a "Phase GN" never does.

---

## LANGUAGE DETECTION
Determine the project language once, before anything else, by its marker file:

| Marker in project root | `<lang>` | Pack |
| :--- | :--- | :--- |
| `Gemfile` | `ruby` | `agent_docs/ruby/` |
| `pyproject.toml` / `setup.py` / `setup.cfg` | `python` | `agent_docs/python/` |

Throughout this document, `<lang>` resolves to the detected language. If both or neither marker is present, ask the user which pack applies before proceeding.

## WORKSPACE CROSS-REFERENCES
When executing changes under this playbook, dynamically reference the sibling documentation in your language pack as needs arise:
*   Refer to `<lang>/code_conventions.md` for formatting, layout, styling, and structural syntax rules.
*   Refer to `<lang>/running_tests.md` for specific test suite engine configurations and execution flags.
*   Refer to `<lang>/database_schema.md` for custom conventions regarding indexes, queries, and migrations.
*   Refer to `<lang>/toolchain.md` for the exact linter, formatter, security scanner, N+1/perf check, dependency manager, and fixer-agent bindings this playbook calls for by role.

---

## PHASE 1: BRANCHING STRATEGY & GIT HYGIENE
Coding is strictly isolated into short-lived, single-purpose feature branches.

### Never Commit Directly to Main
> **Why:** The `main` branch represents stable, production-ready truth. Bypassing pull requests introduces unverified regressions, circumvents automated security pipelines, and degrades code review audit trails. Feature branches keep experimental code safely contained until proven resilient.
>
> This rule is enforced deterministically: the pre-commit hook (`.claude/hooks/pre-commit-gate.sh`) blocks any `git commit` on `main`/`master` in a supported project, regardless of language.

### Branch Naming & Merge Flow
*   Branch from an up-to-date `main`: `git checkout -b <type>/<short-kebab-description>` — e.g. `feature/order-cancellation`, `fix/nil-gateway-timeout`, `refactor/extract-payment-service`.
*   Keep branches single-purpose and short-lived (days, not weeks). Rebase on `main` if it drifts.
*   Merge back via pull request only. Never merge locally into `main`. Open the PR when the feature's full TDD loop is complete, the suite is green, and the **Feature-Completion Review** (Phase 4) is clean.

### Feature Doc Close-Out (after the PR merges)
A feature doc (`docs/features/<feature>.md`) is **working state, not documentation** — it exists only while its feature is in flight. When the feature's PR merges:

1. **Promote anything durable.** A decision that future features must honor goes into the project's `CLAUDE.md`; a correction to a playbook goes into the project's `agent_docs/` override of that file. Most entries need no promotion — they only mattered while the work was open.
    *   **Promote by consolidating, never by appending.** `CLAUDE.md` is loaded into every session — each promotion should rewrite or extend the relevant existing section in a line or two, not add a new block. If a promotion would push `CLAUDE.md` past roughly 100 lines, tighten the file as part of the same edit.
2. **Capture project lessons** (see below): propose any generalizable patterns this feature surfaced; write only what the user confirms into `docs/lessons.md`.
3. **Delete the doc** in the post-merge cleanup. Git history preserves it permanently (`git log --all -- 'docs/features/<feature>.md'`).

This keeps `docs/features/` listing only in-flight work — it never grows beyond the number of features actually in progress, regardless of project age.

### Project Lessons (`docs/lessons.md`)
Rules live in `CLAUDE.md`; feature-specific state dies with the feature doc. A third kind of knowledge fits neither: **experience gained while applying the rules** — "service objects here grow past 200 lines within three features, split early", "this gem's retry API silently swallows timeouts". Those accumulate in `docs/lessons.md`, one bullet per entry:

```
- YYYY-MM-DD [context] pattern — actionable takeaway   (context: design | implementation | review | bugfix)
```

Guardrails — all four are hard rules:
*   **User-confirmed only.** Propose candidates at close-out (or mid-feature when one would otherwise be lost); the user accepts, edits, or rejects each. Never write autonomously.
*   **Generalization test** before proposing: the entry names a pattern (not a feature fact), and someone on an unrelated feature could act on it without this feature's context. Fails either half → don't propose.
*   **Two lines max** per entry, scannable in seconds.
*   **Tighten & promote.** An entry that recurs ~3+ times is a rule — promote it into `CLAUDE.md` (or the relevant `agent_docs/` override) and remove it here. When the file passes ~30 entries, propose consolidation. The file must never become a log.

**Load:** the Feature Planning Gate (Phase 2) reads `docs/lessons.md` when it exists and surfaces the entries relevant to the planned feature as soft guidance. Missing file = no lessons yet; continue silently.

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
> **Exemption — framework scaffolding:** files produced by the approved framework generators (e.g. Rails `generate model/migration/controller`, Django `startapp`/`makemigrations` — see the generator policy in your language pack's `building_the_project.md` and the project `CLAUDE.md`) do not count as implementation code. The gate applies to behavior: methods, scopes, queries, validations, business logic.

### Feature Planning Gate (mandatory before every feature)
Before the TDD loop begins for any feature, you must produce a **feature-scoped to-do list**. This is separate from the project-level to-do list produced in Phase G2 of `building_the_project.md`.

**Resume check first:** look in `docs/features/` for an existing doc for this feature. If one exists, load it, honor every logged decision and constraint as an active commitment, and continue from the first unchecked task — do not re-plan from scratch.

**Load project lessons:** if `docs/lessons.md` exists (see Phase 1), read it and surface the entries relevant to this feature as soft guidance while planning. Missing file — continue silently.

For a new feature, decompose it into its atomic implementation tasks and write them to `docs/features/<feature-kebab-name>.md` (create the directory if needed). A task is atomic when it maps to a single spec and a single production change. Template:

```
## Feature: <name>
**Branch:** <type>/<kebab-description>
**Review pacing:** per-cycle | autonomous

### Task list
- [ ] spec: <what the test covers>
- [ ] impl: <what the implementation does>
- [ ] spec: ...
- [ ] impl: ...

### Decisions
- <decision and why — appended as cycles complete>

### Traps / dead ends
- <approach that failed and why — so it isn't retried>

### Open questions
- <unresolved item, and what it blocks>
```

Keep the doc tight: one line per decision/trap entry, and when a section grows past ~10 entries, consolidate it — merge related entries and drop ones made irrelevant by later work. A feature doc that needs more than ~80 lines is usually a sign the feature should be split.

Present this list to the user and receive acknowledgement before proceeding. Mark each item completed as you progress — do not advance to the next item until the current TDD loop (Steps 1–5) is complete.

When presenting the list, also ask the user to choose a **review pacing** (use the AskUserQuestion tool — one question, two options, per-cycle marked as recommended):

1. **Per-cycle review** (default) — pause after each completed TDD loop for user review before starting the next item.
2. **Autonomous** — work through the whole checklist and present the completed feature at the end. Even in this mode, pause immediately if a task requires significant deviation from the approved list (a new dependency, a schema change not on the list, a changed public interface).

Default to per-cycle review if the user expresses no preference.

### Optional: UX alignment (UI-facing features)
If the feature adds or changes a user-facing surface, offer the user a brief high-level UX alignment before writing specs — via the AskUserQuestion tool, recommended only when there is a real UI delta. Keep it to what the specs need: which page/route the feature lives on, its entry point from existing navigation, and the empty/error states. Fold the outcome into the feature doc's **Decisions** section. Skip silently for non-UI work (model logic, jobs, internal refactors) — do not prompt when there is nothing to align.

[1. Write Test] ──> [2. Verify Failure] ──> [3. Commit Test] ──> [4. Write Code] ──> [5. Commit Pass]

### Step 1: Write Tests First
*   Begin by describing the desired functionality and writing tests for a new feature that does not yet exist.
*   Create and save the spec file before any implementation file is touched — this is the entry gate to the cycle.

### Step 2: Confirm Tests Fail
*   Execute the newly written specs immediately using your built-in Bash tool.
*   **Mandatory Check:** Verify that the suite fails, and ensure it fails *for the correct reasons* (e.g., missing method, uninitialized constant, import error), proving the test is accurately targeting the code gap.

### Step 3: Commit Failing Tests
*   Commit the failing test suite to your feature branch. This establishes a clear, verifiable definition of "done" inside the repository history.

### Step 4: Write Code to Pass
*   Write the implementation code with the sole goal of making all the committed tests pass.
*   ❌ **Never alter, weaken, or delete committed test files to force a green light.** This is an absolute rule with no exceptions. If a committed test turns out to be genuinely wrong, stop and raise it with the user instead. Refer to `<lang>/running_tests.md` for correct execution parameters.

### Step 5: Commit Passing Code
*   Once tests pass, clear the **Pre-Commit Verification Gate** (detailed below) and commit the implementation code, completing the atomic TDD loop.
*   **Update the feature doc:** mark the completed tasks done in `docs/features/<feature>.md`, and append any decisions made this cycle (library choices, pattern selections, deviations from the plan), failed approaches to Traps, and resolved or new Open Questions. The doc is what lets a future session resume without re-deriving context.

### Pre-Present Verification (every TDD loop)
Before presenting code from Step 1 or Step 4 to the user, verify it — generate first, then check, then present:

*   If the loop touched a **migration / schema change** — run the Self-Validation Checklist in `<lang>/database_schema.md`.
*   If the loop wrote or changed **specs** — run the Self-Validation Checklist in `<lang>/running_tests.md`.
*   Check the conventions in `<lang>/code_conventions.md` that the linter can't enforce (predicate naming, magic-value constants, memoization/caching safety).

Fix violations before presenting — never present code you know fails a checklist. When everything passes, a one-line compliance note is enough; be verbose only when reporting violations and their fixes. If a checklist surfaces a genuine judgment call, present the options with trade-offs via the AskUserQuestion tool (recommended option first) instead of silently choosing.

---

## PHASE 3: PRE-COMMIT VERIFICATION GATE
The gate has two layers — one enforced by the harness, one that remains your responsibility. The concrete tools for each role (linter, security scanner, N+1/perf check, fixer agent) are named in `<lang>/toolchain.md`.

### Enforced automatically (PreToolUse hook)
`.claude/hooks/pre-commit-gate.sh` intercepts every `git commit` in a supported project and blocks it unless:

1.  The current branch is not `main`/`master`.
2.  The language's **linter** (and **formatter check**, where the toolchain defines one) is clean on the files the commit touches.
3.  The language's **security scanner** reports no warnings in those files (when installed).

The hook dispatches on the marker file and runs the right toolchain — see `<lang>/toolchain.md` for the exact commands. Checks 2–3 are **scoped to the commit's changed files** (staged + unstaged vs `HEAD`), so pre-existing offenses elsewhere in the repo never block a commit — full-repo sweeps belong to CI and the Phase 4 review. The hook does **not** run the test suite, because TDD Step 3 commits intentionally failing tests.

### Your responsibility before an implementation commit (Step 5)
1.  **Performance / N+1 audit:** Run the test suite with the language's N+1/perf detector enabled (see `<lang>/toolchain.md`) to catch query and eager-loading regressions introduced by the change.
2.  **Style Cleanup:** Run the language's auto-formatter/auto-correct. If residual offenses remain, invoke the language's **fixer sub-agent** (named in `<lang>/toolchain.md`) with the list of changed files. Any `UNRESOLVABLE` offenses in its report require human review before committing.
3.  **Green Suite:** The full suite passes. If any check fails, fix it on the feature branch before committing again.

---

## PHASE 4: FEATURE-COMPLETION REVIEW (before opening the PR)
The pre-commit gate (Phase 3) is mechanical and commit-scoped — it enforces style and security on every commit but never looks at the feature as a whole, and it cannot judge duplication or design. Once every TDD loop is done and the suite is green, run the **review-and-fix loop** below over the entire feature diff (`git diff main...HEAD`) before opening the PR. This is a loop, not a single pass: you re-review after every round of fixes and only stop when a pass surfaces nothing. The loop's rigor is fixed; its **cost scales with the diff** — small diffs get a single combined reviewer, and re-review rounds are scoped to what the fixes could plausibly have broken.

> **Why a step, not a hook:** style (the linter) and security (the scanner) are deterministic, so they are already hook-enforced on every commit. DRY, design, and altitude are judgment calls — no shell check can make them — so this pass stays the agent's responsibility, gated here before the PR.

### Review scale — size the effort to the diff
Measure the feature diff once before round 1: `git diff main...HEAD --stat`, counting changed lines outside `docs/` and lockfiles. The size picks the dispatch mode:

*   **Small diff (under ~200 changed lines): combined pass.** One `diff-reviewer` invocation with dimension `all` — a single fresh-context agent covers all four dimensions over the whole diff. Do not fan out four agents over a diff a single reviewer can hold; the fan-out's per-agent overhead (each re-reads the diff and playbooks) costs more than it adds on a small change.
*   **Large diff: per-dimension fan-out.** Prefer a dedicated review skill when one is installed in the project; otherwise one `diff-reviewer` invocation per dimension, passing the dimension, the diff range, and the language.

Either way the agent reviews with fresh context (by Phase 4 your own context is at its fullest and your judgment of your own code at its weakest), returns severity-ordered findings or `CLEAN`, and never edits. Fall back to reviewing manually against the referenced playbook only if the agent is unavailable. The concrete tool names per dimension live in `<lang>/toolchain.md`; the registry of advised tools (why each is worth installing, with fallbacks) is `core/orchestration.md`.

### The review dimensions
Every round — combined or fanned out — judges all four dimensions against the whole diff.

| Dimension | Preferred skill (if installed) | `diff-reviewer` / manual focus |
| :--- | :--- | :--- |
| Style & conventions | `/code-review` or `/review` | `<lang>/code_conventions.md` — drift the linter can't catch |
| Security | `/security-review` | authz gaps, mass-assignment, injection, beyond what the scanner flags |
| Duplication / DRY & design | `/simplify` | repeated logic, fat controllers/views, functions doing too much, missing service objects |
| Performance / N+1 | — | confirm the per-commit N+1/perf audits (Phase 3) hold across the full feature flow — run the request/system specs with the detector once more end-to-end |

### The loop
Repeat until a clean round:

1. **Review.** Run a full pass — all four dimensions at the dispatch mode the diff size picked — over the current feature diff and collect all findings.
2. **No findings?** Record "round N: clean" in the feature doc's `### Review log`, then the loop is complete — proceed to open the PR. A clean round that isn't logged doesn't count.
3. **Findings exist?** **Record them first** — append the round to a `### Review log` section of the feature doc (`docs/features/<feature>.md`): round number, then a severity-ordered list (file:line, the problem, the proposed fix). Then report that list to the user. Do not start editing before recording. The log is what lets a session resumed mid-loop know which round it is in and which findings are still open — never rely on the conversation alone to carry loop state.
4. **Fix.** Resolve each finding on the feature branch.
    *   For a genuine judgment call (a refactor that changes a public interface, a security trade-off, two equally valid designs), **ask the user via the AskUserQuestion tool before fixing** — do not decide silently.
    *   ❌ Never weaken or delete a committed spec to clear a finding (Phase 2, Step 4 still applies). If a fix changes behaviour, it goes through its own test-first cycle.
    *   After fixing, re-run the relevant specs and the Phase 3 gate so the fixes are themselves green and committed.
    *   Record any non-obvious decision in the feature doc's **Decisions** section.
5. **Re-review — scope it to what the fixes could have broken:**
    *   The round had a **BLOCKER/MAJOR finding, or any fix was cross-cutting** (touched a public interface, the schema, or code shared beyond the fixed spot) → go back to step 1: a full pass, because a significant fix can introduce a finding in any dimension.
    *   The round's findings were **all MINOR and every fix was localized** → run one **combined confirmation pass** instead: a single `diff-reviewer` invocation (dimension `all`) over the updated feature diff. If it comes back clean, record "round N: clean (confirmation)" and the loop is complete. If it surfaces new findings, treat them as a new round at step 3.

Do not exit the loop early or open the PR on a round that still has open findings. The loop ends only on a logged clean pass — a full round or a confirmation pass — with nothing open.
