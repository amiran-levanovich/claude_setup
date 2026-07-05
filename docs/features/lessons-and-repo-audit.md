## Feature: lessons-and-repo-audit
**Branch:** feature/lessons-and-repo-audit
**Review pacing:** autonomous

Close two long-standing gaps in the kit, sized against the bloat test (recurring value,
bounded footprint):

1. **Knowledge lost at close-out.** The workflow promotes durable *rules* to `CLAUDE.md`
   and deletes the feature doc/brief when work merges — but generalizable *experience*
   ("service objects here grow past 200 lines within three features", "this gem's retry
   API swallows timeouts") is neither, and currently evaporates. → A **project lessons**
   convention: a curated `docs/lessons.md` (dev) / `craft/lessons.md` (craft) file.
2. **Manual maintenance sweeps.** CLAUDE.md imposes sync/stale-reference obligations as
   prose executed by hand on every structural PR. → A maintainer-only **`repo-audit`**
   skill in this repo's own `.claude/skills/` (shipped to no one) that mechanizes them.

**Considered and rejected (bloat test):** a durable review-trend log (upkeep for data a
solo maintainer won't consult; conflicts with bounded-state design) and standalone
interview skills for generating standards (the project-root `agent_docs/` override plus a
small `workflow-init` tailoring step covers it without new skills).

### Task list
- [x] repo-audit: write `.claude/skills/repo-audit/SKILL.md` (inventory → audit → fix → verify)
- [x] repo-audit: register in CLAUDE.md (layout + maintenance conventions)
- [x] dev-workflow: lessons convention in `core/coding_workflow.md` (close-out capture + planning-gate load + guardrails block)
- [x] dev-workflow: README mention under "Per-feature living docs"
- [x] dev-workflow: `workflow-init` — conventions-tailoring offer + lessons-file status line
- [x] craft-workflow: twin convention in `core/craft_workflow.md` (Step 2 close-out + load; `craft/lessons.md`)
- [x] craft-workflow: README mention
- [x] version bumps: dev-workflow 3.2.0 → 3.3.0, craft-workflow 1.1.1 → 1.2.0
- [x] verify: repo-audit pass on this repo clean; JSON valid; `bash -n` clean; stale-ref sweep clean

### Success criteria
1. `.claude/skills/repo-audit/SKILL.md` exists outside both plugin dirs, with valid
   frontmatter, [GAP]/[STALE]/[WRONG] findings format, and a verification step that must
   come back clean; running its audit on this repo (post-change) finds nothing.
2. Both workflow kernels carry the lessons convention with all four guardrails —
   user-confirmed entries only, generalization test, ≤ 2-line entries, tighten/promote
   path — plus a load hook at planning time and a capture hook at close-out.
3. Kernel additions stay compact (≤ ~25 lines each); quickref floors untouched.
4. Verification suite passes: manifests valid JSON, hook scripts pass `bash -n`, no stale
   references, README/CLAUDE.md reflect the new structure.
5. Plugin versions bumped (minor — additive conventions).

### Decisions
- `repo-audit` holds its procedure inline — a deliberate exception to "skills are thin
  pointers", which governs the shipped plugins; there is no docs layer for repo
  maintenance and CLAUDE.md stays the authority it points at.
- Lessons files live beside the working-state dirs (`docs/lessons.md`, `craft/lessons.md`),
  not in `agent_docs/` or `CLAUDE.md`: experiential project state, not kit knowledge or rules.
- Conventions tailoring folded into `workflow-init` Step 3 instead of a standalone skill;
  it copies the pack playbook and appends a project section, so the base is never lost.
- Prompt-discipline hardening (STOP boundaries, checkbox scans, show-your-work) audited
  and found already present in the kernels and pack checklists — no change needed.

### Traps / dead ends
- Rewriting `plugin.json` via a JSON round-trip reformats the keywords array — bump
  versions with a targeted line edit instead.

### Open questions
- (none)

### Review log
- round 1: 1 finding — kernel's lessons block claimed the Planning Gate loads
  `docs/lessons.md`, but Phase 2 lacked the load instruction; fixed (load line added to
  the Feature Planning Gate).
- round 2: clean (JSON valid, `bash -n` clean, stale-name sweep empty, manifest paths
  resolve, plugin symmetry holds).
