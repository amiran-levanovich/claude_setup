# Daily Feature Engineering & TDD Lifecycle

The mandatory day-to-day workflow for writing, testing, linting, and committing features. It is **language-agnostic** — every concrete tool (linter, security scanner, test runner, N+1/perf check, fixer agent) is bound by role in `<lang>/toolchain.md`.

> **Context tight or lost?** `core/quickref.md` is the distilled 10-rule floor with a "when lost" protocol — re-read it instead of guessing.

## EXECUTION TIMELINE

The phases below are **thematic groupings, not a chronology**. What actually runs, in order:

```
P1 branch → P2 planning gate → ⟳ TDD cycle (P2 Steps 1–5; the P3 gate fires on every commit)
          → P4 review loop (until a logged clean pass) → PR → merge → close-out
```

- **Phase 3 is not a stage after Phase 2** — its hook half intercepts *every* `git commit`; its agent half runs before every implementation commit (Step 5). It never runs "once".
- **After the PR merges**, run the feature close-out: `core/feature_closeout.md` (promote durable decisions, propose lessons, delete the feature doc). Read it then, not before.
- **Greenfield projects** use a separate sequence, Phases G0–G4, in `<lang>/building_the_project.md`. A bare "Phase N" always refers to this document.

## LANGUAGE & PACK

Detect the language once, before anything else, by marker file in the project root (one existence check — never a recursive search): `Gemfile` → `ruby`; `pyproject.toml`/`setup.py`/`setup.cfg` → `python`. Both or neither present → ask the user. `<lang>` resolves to the matching pack, `agent_docs/<lang>/` — reference its files as needs arise: `code_conventions.md` (structure and style the linter can't check), `running_tests.md` (test engine and flags), `database_schema.md` (indexes, queries, migrations), `toolchain.md` (every concrete tool binding).

---

## PHASE 1: BRANCHING & GIT HYGIENE

*   **Never commit directly to `main`** — it is production truth; direct commits bypass review and its audit trail. Hook-enforced by `.claude/hooks/pre-commit-gate.sh` regardless of language.
*   Branch from an up-to-date `main`: `<type>/<short-kebab-description>` — e.g. `feature/order-cancellation`, `fix/nil-gateway-timeout`. Single-purpose, short-lived (days, not weeks); rebase on `main` if it drifts.
*   Merge back via pull request only — never locally. Open the PR when every TDD loop is done, the suite is green, and the Phase 4 review is clean.
*   **After the merge**, run `core/feature_closeout.md` — the feature doc is working state and must not outlive its feature.

### Commit messages — Conventional Commits
`<type>(<scope>): <description>`, standard types (`feat` | `fix` | `test` | `refactor` | `chore` | `docs` | `perf`); TDD Step 3 failing-test commits use `test`. Hard rules: **subject ≤ 60 characters** (reword until it fits); description lowercase, imperative mood, no trailing period; breaking change → `!` after the type (`feat(api)!: …`).

---

## PHASE 2: THE TDD CYCLE

> ❌ **Tests come first.** No implementation code before the corresponding spec exists and is committed. If you find yourself opening an implementation file before its spec file, stop and return to Step 1.
>
> **Exemption:** files produced by the approved framework generators (Rails `generate …`, Django `startapp`/`makemigrations` — see the generator policy in `building_the_project.md` and the project `CLAUDE.md`). The gate applies to behavior: methods, scopes, queries, validations, business logic.

### Feature Planning Gate (mandatory before every feature)

**Resume check first:** if `docs/features/<feature>.md` exists, load it, honor every logged decision and constraint as an active commitment, and continue from the first unchecked task — do not re-plan.

**Load lessons:** if `docs/lessons.md` exists, surface its entries relevant to this feature as soft guidance. Missing file — continue silently.

For a new feature, decompose it into atomic tasks — each mapping to a single spec and a single production change — in `docs/features/<feature-kebab-name>.md` (create the directory if needed):

```
## Feature: <name>
**Branch:** <type>/<kebab-description>
**Review pacing:** per-cycle | autonomous

### Task list
- [ ] spec: <what the test covers>
- [ ] impl: <what the implementation does>

### Decisions
- <decision and why — appended as cycles complete>

### Traps / dead ends
- <approach that failed and why — so it isn't retried>

### Open questions
- <unresolved item, and what it blocks>
```

Keep the doc tight: one line per decision/trap entry; consolidate any section past ~10 entries; a doc needing more than ~80 lines usually means the feature should be split.

Present the list for acknowledgement before proceeding, and ask the **review pacing** via the AskUserQuestion tool (one question, per-cycle recommended): **per-cycle** (default) — pause after each completed TDD loop for user review; or **autonomous** — present the finished feature at the end, still pausing immediately for any significant deviation from the approved list (a new dependency, an unplanned schema change, a changed public interface).

**UI-facing features only:** before writing specs, offer a brief UX alignment via AskUserQuestion — which page/route the feature lives on, its entry point from existing navigation, the empty/error states — and fold the outcome into Decisions. Skip silently for non-UI work; do not prompt when there is nothing to align.

### The cycle

[1. Write Test] ──> [2. Verify Failure] ──> [3. Commit Test] ──> [4. Write Code] ──> [5. Commit Pass]

1. **Write the spec first** — create and save the spec file before any implementation file is touched.
2. **Confirm it fails for the right reason** (missing method, uninitialized constant, import error) — proof the test targets the code gap.
3. **Commit the failing spec** — a verifiable definition of "done" in repository history.
4. **Write code to make it pass.** ❌ **Never alter, weaken, or delete a committed test to force a green light — no exceptions.** A committed test that seems genuinely wrong → stop and raise it with the user. Execution parameters: `<lang>/running_tests.md`.
5. **Clear the Phase 3 gate, commit, and update the feature doc** — mark tasks done; append this cycle's Decisions, Traps, and Open-question changes. The doc is what lets a future session resume without re-deriving context.

**Pre-present verification, every loop:** before presenting Step 1 or Step 4 code — a migration/schema change → run the Self-Validation Checklist in `<lang>/database_schema.md`; new or changed specs → the one in `<lang>/running_tests.md`; always → the conventions the linter can't enforce (`<lang>/code_conventions.md`). Fix violations before presenting — never present code you know fails a checklist; when clean, a one-line compliance note suffices. A genuine judgment call → AskUserQuestion with options, recommended first — never choose silently.

---

## PHASE 3: PRE-COMMIT VERIFICATION GATE

**Hook-enforced:** `.claude/hooks/pre-commit-gate.sh` intercepts every `git commit` in a supported project and blocks it unless (1) the branch is not `main`/`master`, (2) the linter (+ formatter check where the toolchain defines one) is clean on the commit's changed files (staged + unstaged vs `HEAD`), and (3) the security scanner reports nothing on those files (when installed). Changed-files scoping keeps pre-existing debt from ever blocking a commit — full-repo sweeps belong to CI and Phase 4. It never runs the test suite, because Step 3 commits intentionally failing specs.

**Your responsibility before an implementation commit (Step 5):**
1.  **N+1/perf audit** — run the suite with the language's detector enabled (`<lang>/toolchain.md`).
2.  **Style cleanup** — run the auto-formatter/auto-correct; residual offenses → the language's fixer sub-agent; any `UNRESOLVABLE` in its report requires human review before committing.
3.  **Green suite** — the full suite passes. A failure is fixed on the feature branch before committing again.

---

## PHASE 4: FEATURE-COMPLETION REVIEW (before opening the PR)

The Phase 3 gate is mechanical and commit-scoped; DRY, design, and altitude are judgment calls no shell check can make, and the gate never sees the feature as a whole. Once every TDD loop is done and the suite is green, run this review-and-fix loop over the entire feature diff (`git diff main...HEAD`) before opening the PR. The rigor is fixed; the **cost scales with the diff**.

### Review scale — size the effort to the diff
Measure once before round 1: `git diff main...HEAD --stat`, counting changed lines outside `docs/` and lockfiles.

*   **Small diff (under ~200 changed lines): combined pass** — one `diff-reviewer` invocation with dimension `all`. Do not fan out four agents over a diff a single reviewer can hold; the fan-out's per-agent overhead costs more than it adds.
*   **Large diff: per-dimension fan-out** — a dedicated review skill when one is installed, else one `diff-reviewer` invocation per dimension, passing the dimension, the diff range, and the language.

Either way the reviewer works with fresh context (by Phase 4 your judgment of your own code is at its weakest), returns severity-ordered findings or `CLEAN`, and never edits. Agent unavailable → review manually against the playbooks below. Tool bindings: `<lang>/toolchain.md`; advised-tools registry: `core/orchestration.md`.

### The review dimensions
Every round — combined or fanned out — judges all four dimensions against the whole diff.

| Dimension                  | Preferred skill (if installed) | `diff-reviewer` / manual focus                                                                                                                           |
| :------------------------- | :----------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Style & conventions        | `/code-review` or `/review`    | `<lang>/code_conventions.md` — drift the linter can't catch                                                                                              |
| Security                   | `/security-review`             | authz gaps, mass-assignment, injection, beyond what the scanner flags                                                                                    |
| Duplication / DRY & design | `/simplify`                    | repeated logic, fat controllers/views, functions doing too much, missing service objects                                                                 |
| Performance / N+1          | —                              | confirm the per-commit N+1/perf audits (Phase 3) hold across the full feature flow — run the request/system specs with the detector once more end-to-end |

### The loop
Repeat until a logged clean pass:

1. **Review** — a full pass: all four dimensions, at the dispatch mode the diff size picked.
2. **No findings?** Record "round N: clean" in the feature doc's `### Review log` — an unlogged clean round doesn't count — then open the PR.
3. **Findings?** **Record them first** in the Review log (round number, then a severity-ordered list: `file:line — problem — proposed fix`), then report them to the user. Never start editing before recording — the log is what lets a resumed session know which round it is in and which findings are open; the conversation does not carry loop state.
4. **Fix** each finding on the feature branch. A genuine judgment call (public-interface refactor, security trade-off, two valid designs) → AskUserQuestion before fixing. ❌ Never weaken or delete a committed spec to clear a finding — a behaviour-changing fix goes through its own test-first cycle. Re-run the relevant specs and the Phase 3 gate so fixes are green and committed; record non-obvious decisions in the feature doc.
5. **Re-review — scoped to what the fixes could have broken:**
    *   The round had a **BLOCKER/MAJOR finding, or any fix was cross-cutting** (public interface, schema, code shared beyond the fixed spot) → back to step 1, full pass — a significant fix can introduce a finding in any dimension.
    *   The findings were **all MINOR and every fix localized** → one **combined confirmation pass** (`diff-reviewer`, dimension `all`) over the updated diff. Clean → log "round N: clean (confirmation)"; the loop is complete. New findings → a new round at step 3.

Never exit the loop or open the PR with an open finding. The loop ends only on a logged clean pass — a full round or a confirmation pass.
