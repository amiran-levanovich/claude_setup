---
name: tdd-workflow
description: Use when implementing any feature, bugfix, or refactor in a Ruby/Rails or Python (Django/FastAPI) project, or when the user says 'implement', 'build this feature', 'add this functionality', 'fix this bug', 'refactor this', 'finish this feature', 'ready for a PR', or 'review before merging'. Covers branching, the feature-scoped to-do list, the TDD cycle (test-first, commit failing tests, then implement), the pre-commit verification gate, and the feature-completion review loop (review → fix → re-review until clean) before opening the PR.
---

Read `agent_docs/core/coding_workflow.md` and follow it. Locate it as follows: use `agent_docs/core/coding_workflow.md` in the project root if present (drop-in install); otherwise read `../../../agent_docs/core/coding_workflow.md` relative to this skill's directory (plugin install). Those two locations are the only ones: if neither resolves, report the broken install and stop — never search the filesystem for `agent_docs`.

It is the single, **language-agnostic** source of truth for the day-to-day TDD lifecycle, branch/commit hygiene, and the pre-commit gate. The spine detects the project language by marker file in the project root (`Gemfile` → `ruby`, `pyproject.toml`/`setup.py`/`setup.cfg` → `python`) and routes the concrete tool commands to the matching `agent_docs/<lang>/toolchain.md`. Read that toolchain file too once the language is known.

Before planning any feature, check `docs/features/` in the project root for an in-flight doc matching the feature — if one exists, load it and resume from its task list, honoring its logged decisions, instead of re-planning. A missing `docs/features/` directory just means nothing is in flight — plan fresh; don't search elsewhere for feature docs.

If context is tight (post-compaction, near the limit, or you are unsure of the rules), read `agent_docs/core/quickref.md` (same path resolution) — it is the distilled 11-rule floor and the "when lost" protocol.
