# diff-reviewer sub-agent

**Branch:** feat/diff-reviewer-agent
**Status:** implemented — PR pending. Raised 2026-07-04.

## Why

REVIEW.md finding C1: the kit's identity (the Phase 4 review loop) was 100 % context-resident,
running at the exact moment the main session is fullest and most degraded. A fresh-context
sub-agent reviewer floors that: unbiased by having written the code, immune to session length,
and it upgrades the no-skill fallback from "degraded main agent scans the diff manually".

## Task list

- [x] agent definition `dev-workflow/.claude/agents/diff-reviewer.md`
- [x] plugin.json: agents list + version 3.0.0 → 3.1.0
- [x] coding_workflow.md Phase 4: dispatch order skill → agent → manual
- [x] orchestration.md: three "Without it" fallbacks + bundled list
- [x] quickref.md rule 9: dispatch pointer
- [x] both toolchain.md role tables: Review sub-agent row
- [x] dev-workflow README: tree, agent paragraph, ships-with list, highlights
- [x] CLAUDE.md layout: agents line

## Decisions

- **One parameterized agent, not four**: dimension passed in the prompt keeps the
  always-loaded description cost to a single entry.
- **`model: inherit`** (fixers pin `sonnet`): review is judgment work, fixers are mechanical.
- **Read/Grep/Glob/Bash, no Edit**: findings-only contract; the main session applies fixes
  through the normal TDD/gate path.
- **No craft-workflow parallel**: craft review depends on accumulated discovery/brief context —
  exactly what a cold sub-agent lacks. The asymmetry stands (CLAUDE.md).
- **Never CLEAN on a partial review**: explicit output-contract rule, mirroring the
  hallucinated-compliance concern from the degradation analysis.

## Traps

- Agent frontmatter descriptions load into every consumer session — keep them one entry
  per capability and resist agent sprawl.

## Review log

- **Round 1 (2026-07-04): clean.** plugin.json validates; all relative links resolve
  (scripted sweep); 15 cross-references consistent (spine, registry, quickref, both
  toolchains, README, CLAUDE.md); agent contract matches the fixer pattern
  (frontmatter shape, escalation honesty, findings-only output).
