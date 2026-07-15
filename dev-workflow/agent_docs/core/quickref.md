# Quick Reference — the 11-rule floor

Re-read this when context is tight, after a compaction, or whenever unsure. It is the distilled floor of `coding_workflow.md`, not a replacement — follow the full doc when you can.

1. **Language by marker file in the project root** (one check, never a recursive search): `Gemfile` → ruby, `pyproject.toml`/`setup.py`/`setup.cfg` → python. All concrete commands come from `agent_docs/<lang>/toolchain.md`.
2. **Never commit to `main`** (hook-enforced). Work on `<type>/<kebab-description>` branches; merge by PR only.
3. **Resume, don't re-plan**: if `docs/features/<feature>.md` exists, load it and continue from its task list, honoring every logged decision. Missing doc = nothing in flight: plan fresh, don't search elsewhere.
4. **Spec first**: no implementation code before its failing spec exists, fails for the right reason, and is committed.
5. **Never weaken or delete a committed spec.** If one seems wrong, stop and ask the user.
6. **Before an implementation commit**: green suite + N+1 audit + auto-format (fixer agent for leftovers).
7. **Commits**: Conventional Commits, subject ≤ 60 chars.
8. **Update the feature doc every cycle** — tasks, Decisions, Traps, Review log. The doc is the memory; the conversation is not.
9. **Before the PR**: the review loop (style / security / DRY / N+1) over the full diff — small diff (< ~200 lines) → one `diff-reviewer` pass with dimension `all`; large diff → one agent (or installed review skill) per dimension. After a fix round, a full re-pass only if a MAJOR finding or cross-cutting fix; all-MINOR, localized fixes → one combined confirmation pass. Log every round in the feature doc's Review log; only a *logged* clean pass ends the loop.
10. **Judgment calls → AskUserQuestion** with options. Never decide silently; never guess a fact you can verify.
11. **Act on checked state, not claims.** Before acting on "merged", "CI green", "pushed", "deployed" — whether the claim comes from the user, an agent, or your own memory of earlier in the session — check the real system first. And report success only after the command confirms it (exit 0, the PR actually shows merged); a claim of success is not one.

## When lost

Re-read in this order, stopping as soon as you're oriented: **this file → the feature doc → `core/coding_workflow.md`**. Still unsure → ask the user. Asking is cheap; guessing wrong is not.

## Minimum read set by task

| Task                        | Read                                              |
| :-------------------------- | :------------------------------------------------ |
| Feature / bugfix / refactor | `core/coding_workflow.md` + `<lang>/toolchain.md` |
| Writing tests               | + `<lang>/running_tests.md`                       |
| Schema / migration          | + `<lang>/database_schema.md`                     |
| After the PR merges         | `core/feature_closeout.md`                        |
| New project                 | `<lang>/building_the_project.md`                  |
