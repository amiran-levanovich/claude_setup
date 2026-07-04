# Quick Reference — the 10-rule floor

Re-read this when context is tight, after a compaction, or whenever unsure. It is the distilled floor of `coding_workflow.md`, not a replacement — follow the full doc when you can.

1. **Language by marker file**: `Gemfile` → ruby, `pyproject.toml`/`setup.py`/`setup.cfg` → python. All concrete commands come from `agent_docs/<lang>/toolchain.md`.
2. **Never commit to `main`** (hook-enforced). Work on `<type>/<kebab-description>` branches; merge by PR only.
3. **Resume, don't re-plan**: if `docs/features/<feature>.md` exists, load it and continue from its task list, honoring every logged decision.
4. **Spec first**: no implementation code before its failing spec exists, fails for the right reason, and is committed.
5. **Never weaken or delete a committed spec.** If one seems wrong, stop and ask the user.
6. **Before an implementation commit**: green suite + N+1 audit + auto-format (fixer agent for leftovers).
7. **Commits**: Conventional Commits, subject ≤ 60 chars.
8. **Update the feature doc every cycle** — tasks, Decisions, Traps, Review log. The doc is the memory; the conversation is not.
9. **Before the PR**: the review loop (style / security / DRY / N+1) over the full diff — no review skill installed → dispatch each dimension to the `diff-reviewer` agent. Log every round in the feature doc's Review log; only a *logged* clean round ends the loop.
10. **Judgment calls → AskUserQuestion** with options. Never decide silently; never guess a fact you can verify.

## When lost

Re-read in this order, stopping as soon as you're oriented: **this file → the feature doc → `core/coding_workflow.md`**. Still unsure → ask the user. Asking is cheap; guessing wrong is not.

## Minimum read set by task

| Task | Read |
| :--- | :--- |
| Feature / bugfix / refactor | `core/coding_workflow.md` + `<lang>/toolchain.md` |
| Writing tests | + `<lang>/running_tests.md` |
| Schema / migration | + `<lang>/database_schema.md` |
| New project | `<lang>/building_the_project.md` |
