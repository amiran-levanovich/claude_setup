# Orchestration Registry — advised tools & the availability check

The dev-workflow kit is **self-sufficient**: the pre-commit hook, the `agent_docs/` knowledge base, and the bundled fixer agents ship with the plugin and need nothing else. The tools below are **advised, not required** — each raises quality for one role, and every role has a manual fallback. This file is the dev sibling of `craft_docs/core/orchestration.md`.

> **Principle:** the kit supplies the *method* and the deterministic floor; these tools supply extra *leverage*. Never block on a missing advised tool — fall back and note the absence.

> **Parallel agents get isolated state.** Read-only agents (reviewers, explorers) fan out freely. Agents that *modify the tree* never run in parallel against a shared checkout — shared working state is how parallel agents cross-contaminate. Give each its own git worktree (worktree isolation if the harness offers it), or run them sequentially.

## The availability check (run by `workflow-init`)

1. Inspect the **skills and tools actually available to you this session** (your available-skills list, agents, and MCP tools).
2. For each advised entry below, mark **Available ✓** or **Not present**.
3. Report a compact table: role, tool, present/absent — with the one-line "adds" and install pointer for anything missing.
4. **Never block.** Every entry has a fallback; the check is informational.

A capability may exist under a different name (workspaces often namespace skills) — any equivalent skill filling the same role counts.

## Advised tools

### `/code-review` or `/review` — style review (Phase 4)
- **Adds:** structured diff review that catches drift the linter can't.
- **Without it:** the bundled `diff-reviewer` agent (dimension: `style`).

### `/security-review` — security review (Phase 4)
- **Adds:** judgment-layer audit on top of the scanner — authz gaps, mass-assignment, injection.
- **Without it:** the bundled `diff-reviewer` agent (dimension: `security`) on top of the language's scanner.

### `/simplify` — DRY / design review (Phase 4)
- **Adds:** finds duplication, fat controllers, and altitude problems mechanically.
- **Without it:** the bundled `diff-reviewer` agent (dimension: `dry-design`).

### `plannotator` — artifact review (greenfield Phases G0–G2)
- **Adds:** per-section human annotations on the requirements/UX/roadmap docs — precise, tracked, actionable.
- **Install:** [backnotprop/plannotator](https://github.com/backnotprop/plannotator)
- **Without it:** iterate over the inline markdown document instead.

### `impeccable` — frontend design quality (UI-facing features only)
- **Adds:** design `critique`/`audit`/`polish` commands, live browser iteration, and deterministic detector rules for AI-generated frontend — complements the Phase 4 dimensions when a feature ships a user-facing surface.
- **Install:** `npx impeccable install` ([pbakaus/impeccable](https://github.com/pbakaus/impeccable))
- **Without it:** the optional UX-alignment step in `coding_workflow.md` plus manual review of the rendered UI. Irrelevant for headless/API-only work.

### Context7 MCP — current library docs
- **Adds:** version-accurate docs for gems/packages, framework APIs, and migration syntax at the moment you need them — training data goes stale, and a wrong API guess costs a whole TDD cycle.
- **Install:** `npx ctx7 setup --claude`, or `claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp --api-key YOUR_KEY` ([upstash/context7](https://github.com/upstash/context7))
- **Without it:** `WebSearch`/`WebFetch` against the official docs; flag any version-specific answer given from memory.

## Bundled with the plugin (never in the availability report)

The language skills (`tdd-workflow`, `greenfield-setup`, `schema-migrations`, `testing`, `workflow-init`), the `rubocop-fixer`/`ruff-fixer` agents, the `transfer-context` command, and the pre-commit hook — they are the kit itself.
