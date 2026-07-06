# Feature Close-Out (after the PR merges)

The last act of a feature — run once its PR has merged. A feature doc (`docs/features/<feature>.md`) is **working state, not documentation**: it exists only while its feature is in flight, and `docs/features/` must list only in-flight work regardless of project age.

## 1. Promote anything durable

A decision that future features must honor goes into the project's `CLAUDE.md`; a correction to a playbook goes into the project's `agent_docs/` override of that file. Most entries need no promotion — they only mattered while the work was open.

**Promote by consolidating, never by appending.** `CLAUDE.md` is loaded into every session — a promotion rewrites or extends the relevant existing section in a line or two, never adds a new block. If it would push `CLAUDE.md` past roughly 100 lines, tighten the file as part of the same edit.

## 2. Capture project lessons (`docs/lessons.md`)

Rules live in `CLAUDE.md`; feature-specific state dies with the feature doc. A third kind of knowledge fits neither: **experience gained while applying the rules** — "service objects here grow past 200 lines within three features, split early", "this gem's retry API silently swallows timeouts". Those accumulate in `docs/lessons.md`, one bullet per entry:

```
- YYYY-MM-DD [context] pattern — actionable takeaway   (context: design | implementation | review | bugfix)
```

Guardrails — all four are hard rules:

*   **User-confirmed only.** Propose candidates at close-out (or mid-feature when one would otherwise be lost); the user accepts, edits, or rejects each. Never write autonomously.
*   **Generalization test** before proposing: the entry names a pattern (not a feature fact), and someone on an unrelated feature could act on it without this feature's context. Fails either half → don't propose.
*   **Two lines max** per entry, scannable in seconds.
*   **Tighten & promote.** An entry that recurs ~3+ times is a rule — promote it into `CLAUDE.md` (or the relevant `agent_docs/` override) and remove it here. When the file passes ~30 entries, propose consolidation. The file must never become a log.

**Load point:** the Feature Planning Gate (Phase 2 of `coding_workflow.md`) reads `docs/lessons.md` when it exists and surfaces the entries relevant to the planned feature as soft guidance. Missing file = no lessons yet; continue silently.

## 3. Delete the feature doc

Git history preserves it permanently (`git log --all -- 'docs/features/<feature>.md'`). Deleting it is what keeps `docs/features/` an accurate list of open work.
