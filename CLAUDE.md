# CLAUDE.md — maintaining the `claude_setup` repo

This file is **memory for working *on* this repo**, not guidance for a project that uses the kit. Read it before editing.

## What this repo is
`claude_setup` is a **self-hosting Claude Code plugin marketplace** (`.claude-plugin/marketplace.json`) hosting two sibling plugins:

| Plugin | Source | For | Detail |
|---|---|---|---|
| `dev-workflow` | `./` (repo root) | Code — Ruby/Rails & Python | [docs/dev-workflow.md](./docs/dev-workflow.md) |
| `craft-workflow` | `./craft-workflow` | Non-code — design, content, research | [craft-workflow/README.md](./craft-workflow/README.md) |

Both share one method: discovery → plan → **criteria-first** → produce → review-loop until clean. The general overview is [README.md](./README.md).

## This is a docs/plugin repo, NOT an app
It contains markdown, shell, and JSON — no `Gemfile`, no `pyproject.toml`. Consequences when working here:
- The `dev-workflow` **pre-commit hook is inert** in this repo (it keys off a language marker file that doesn't exist here). Do **not** apply the Ruby/Python TDD gate, RuboCop, RSpec, or `bundle`/`rails` commands to maintaining this repo — those govern *projects that install the kit*, not the kit itself.
- There is no test suite. Verification = JSON validates (`python3 -c 'import json…'`), shell passes `bash -n`, markdown links resolve, and a stale-reference sweep is clean.

## Layout
```
.claude-plugin/
├── plugin.json                  # dev-workflow manifest (its plugin root = repo root)
└── marketplace.json             # lists both plugins

# ── dev-workflow (source: ./) ──
.claude/
├── skills/                      # thin routers: greenfield-setup · tdd-workflow · schema-migrations · testing · workflow-init
├── agents/                      # rubocop-fixer · ruff-fixer
├── commands/                    # transfer-context
├── hooks/                       # pre-commit-gate.sh (commit gate) · context-guard.sh (auto-compact guard)
└── settings.json                # hook registration (drop-in mode)
hooks/hooks.json                 # hook registration (plugin mode)
agent_docs/
├── core/                        # coding_workflow.md (spine) · orchestration.md (advised tools) · quickref.md (10-rule floor)
├── ruby/                        # building_the_project · code_conventions · database_schema · running_tests · toolchain
└── python/                      # same five files
docs/dev-workflow.md             # detailed guide

# ── craft-workflow (source: ./craft-workflow) ──
craft-workflow/
├── .claude-plugin/plugin.json
├── .claude/skills/              # craft-init · craft-iterate · craft-review
├── craft_docs/
│   ├── core/                    # craft_workflow.md (kernel) · orchestration.md (advised skills) · quickref.md (9-rule floor)
│   └── {experience-design,content,research}/   # each pack: brief.md · rubric.md · toolchain.md
└── README.md                    # detailed guide

README.md                        # marketplace overview     CLAUDE.md  # this file
```
- **dev-workflow**: skills detect language by marker file (`Gemfile` / `pyproject.toml`…) and route to the matching pack; enforcement = the pre-commit hook + the fixer agents.
- **craft-workflow**: **no hook, no fixer agents** by design — enforcement is agent-run sign-off gates + the review loop.

## Maintenance conventions
- **Keep the two plugins in sync.** They share a design (kernel + packs, `toolchain.md` per pack, an `*-init` skill with an orchestration/availability check). A change to one's structure usually wants a parallel in the other.
- **Don't add a commit hook or fixer agents to craft-workflow** — its quality bar is judgment, carried by the review loop. That asymmetry is intentional.
- **Skills are thin pointers**, not content: a skill's `SKILL.md` detects context and routes to the authoritative `agent_docs/`/`craft_docs/` file. Put substance in the docs, not the skill. Path resolution: project-root copy first, else `../../../<docs>/…` relative to the skill dir.
- **Versioning**: bump the affected plugin's `version` in its `plugin.json` on a meaningful change (breaking renames → major; `dev-workflow` is at 2.x, `craft-workflow` at 1.x).
- **Git**: feature branch → PR into `main` (never commit to `main`); [Conventional Commits](https://www.conventionalcommits.org), subject ≤ 60 chars; end commit messages with the `Co-Authored-By` trailer.
- When editing a pack doc, update its plugin's README/detail doc and this layout if the structure changed; run the verification checks above before committing.
