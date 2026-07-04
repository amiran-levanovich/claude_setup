# dev-workflow detail-doc placement

**Status:** implemented — PR open, pending merge. Raised 2026-07-04, decided 2026-07-04.

## Problem

`docs/` holds a single file, `dev-workflow.md`. It is *not* a duplicate — it is
dev-workflow's canonical detail doc (the counterpart of `craft-workflow/README.md`) —
but the lone-file folder reads as clutter and the asymmetry between the two plugins'
doc locations is non-obvious. Cause: dev-workflow's plugin root is the repo root, so
its "plugin README" slot is already taken by the marketplace overview `README.md`.

## Options considered so far

1. **Leave as is** — zero risk; the asymmetry stays and keeps confusing readers.
2. **Move to repo root** (e.g. `DEV-WORKFLOW.md`) — kills the lone folder; breaks the
   `docs/` convention and three inbound links (root `README.md`, `CLAUDE.md` table,
   `craft-workflow/README.md` sibling link).
3. **Restructure dev-workflow into its own subfolder** (mirror craft-workflow) — cleanest
   symmetry, but a breaking change: `.claude-plugin/plugin.json` source path,
   `hooks/hooks.json`, drop-in copy instructions in the doc itself, and a major version
   bump for dev-workflow (3.0.0).

## Tasks

- [x] Decide between the options (judgment call → ask the user before implementing)
- [x] Update every inbound link and the CLAUDE.md layout section to match
- [x] Option 3 chosen: bump dev-workflow to 3.0.0 and rewrite the Option B drop-in paths

## Decisions

- **Option 3** (user, 2026-07-04): both plugins live in isolated sibling directories with
  the same shape; a lone-file `docs/` at repo root makes no sense. dev-workflow → 3.0.0.
- Repo keeps its own root `.claude/settings.json` registering only the context guard
  (from `dev-workflow/.claude/hooks/`) — the pre-commit gate was always inert here
  (no marker file), so it is not re-registered for maintainer sessions.
- `docs/features/` stays at repo root — it is this repo's working memory, not plugin content.

## Traps

- Any move must update the marketplace/plugin manifests *and* the drop-in copy
  instructions in the doc itself — they hard-code repo-root paths.
- Skills' `../../../agent_docs/…` fallbacks stay valid because `agent_docs/` moved
  *with* the skills under `dev-workflow/`; only repo-root-relative links broke.
- Root `.claude/` still holds untracked session artifacts (`context-transfers/`,
  `settings.local.json`) — never `git mv` the directory wholesale.

## Review log

- **Round 1 (2026-07-04): clean.** All 6 JSON files validate; both hooks pass `bash -n`;
  every relative markdown link resolves (scripted sweep); zero stale `docs/dev-workflow`
  or `source: "./"` references; full diff reviewed — moves are pure `git mv` renames,
  content edits limited to paths/links/version and the two layout trees.
