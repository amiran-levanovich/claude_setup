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
.claude-plugin/{plugin.json (dev-workflow), marketplace.json (lists both)}
.claude/{skills,agents,commands,hooks}/  agent_docs/{core,ruby,python}/   # dev-workflow (root)
hooks/hooks.json                                                          # dev-workflow hook registration
craft-workflow/{.claude-plugin,.claude/skills,craft_docs/{core,experience-design,content,research}}/
docs/dev-workflow.md                                                      # dev-workflow detailed guide
CLAUDE.md (this file)  README.md (general overview)
```
- **dev-workflow**: a language-agnostic spine (`agent_docs/core/coding_workflow.md`) + `ruby/` & `python/` packs; skills detect language by marker file and route to the matching pack; a real pre-commit hook + `rubocop-fixer`/`ruff-fixer` agents.
- **craft-workflow**: a domain-neutral kernel (`craft_docs/core/craft_workflow.md`) + `experience-design`/`content`/`research` packs; **no hook, no fixer agents** by design — enforcement is agent-run sign-off gates + the review loop. Advised external skills live in `craft_docs/core/orchestration.md`.

## Maintenance conventions
- **Keep the two plugins in sync.** They share a design (kernel + packs, `toolchain.md` per pack, an `*-init` skill with an orchestration/availability check). A change to one's structure usually wants a parallel in the other.
- **Don't add a commit hook or fixer agents to craft-workflow** — its quality bar is judgment, carried by the review loop. That asymmetry is intentional.
- **Skills are thin pointers**, not content: a skill's `SKILL.md` detects context and routes to the authoritative `agent_docs/`/`craft_docs/` file. Put substance in the docs, not the skill. Path resolution: project-root copy first, else `../../../<docs>/…` relative to the skill dir.
- **Versioning**: bump the affected plugin's `version` in its `plugin.json` on a meaningful change (breaking renames → major; `dev-workflow` is at 2.x, `craft-workflow` at 1.x).
- **Git**: feature branch → PR into `main` (never commit to `main`); [Conventional Commits](https://www.conventionalcommits.org), subject ≤ 60 chars; end commit messages with the `Co-Authored-By` trailer.
- When editing a pack doc, update its plugin's README/detail doc and this layout if the structure changed; run the verification checks above before committing.
