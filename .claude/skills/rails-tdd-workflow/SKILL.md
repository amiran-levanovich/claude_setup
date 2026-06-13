---
name: rails-tdd-workflow
description: Use when implementing any feature, bugfix, or refactor in a Rails project, or when the user says 'implement', 'build this feature', 'add this functionality', 'fix this bug', 'refactor this', 'finish this feature', 'ready for a PR', or 'review before merging'. Covers branching, the feature-scoped to-do list, the TDD cycle (test-first, commit failing tests, then implement), the pre-commit verification gate, and the feature-completion review loop (review → fix → re-review until clean) before opening the PR.
---

Read `agent_docs/coding_workflow.md` and follow it. Locate it as follows: use `agent_docs/coding_workflow.md` in the project root if present (drop-in install); otherwise read `../../../agent_docs/coding_workflow.md` relative to this skill's directory (plugin install).

It is the single source of truth for the day-to-day TDD lifecycle, branch/commit hygiene, and the pre-commit gate.

Before planning any feature, check `docs/features/` in the project root for an in-flight doc matching the feature — if one exists, load it and resume from its task list, honoring its logged decisions, instead of re-planning.
