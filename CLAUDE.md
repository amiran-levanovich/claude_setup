# CLAUDE.md — maintaining the `claude_setup` repo

This file is **memory for working *on* this repo**, not guidance for a project that uses the kit. Read it before editing.

## What this repo is
`claude_setup` is a **self-hosting Claude Code plugin marketplace** (`.claude-plugin/marketplace.json`) hosting three sibling plugins:

| Plugin           | Source             | For                                                           | Detail                                                 |
| :--------------- | :----------------- | :------------------------------------------------------------ | :----------------------------------------------------- |
| `dev-workflow`   | `./dev-workflow`   | Code — Ruby/Rails & Python                                    | [dev-workflow/README.md](./dev-workflow/README.md)     |
| `craft-workflow` | `./craft-workflow` | Non-code — design, content, research                          | [craft-workflow/README.md](./craft-workflow/README.md) |
| `job-workflow`   | `./job-workflow`   | Job search — candidate knowledge base + tailored applications | [job-workflow/README.md](./job-workflow/README.md)     |

All share one method: discovery → plan → **criteria-first** → produce → review-loop until clean. The general overview is [README.md](./README.md).

## This is a docs/plugin repo, NOT an app
It contains markdown, shell, and JSON — no `Gemfile`, no `pyproject.toml`. Consequences when working here:
- The `dev-workflow` **pre-commit hook is inert** in this repo (it keys off a language marker file that doesn't exist here). Do **not** apply the Ruby/Python TDD gate, RuboCop, RSpec, or `bundle`/`rails` commands to maintaining this repo — those govern *projects that install the kit*, not the kit itself.
- There is no test suite. Verification = JSON validates (`python3 -c 'import json…'`), shell passes `bash -n`, markdown links resolve, and a stale-reference sweep is clean.

## Layout
```
.claude-plugin/marketplace.json  # lists all three plugins

# ── dev-workflow (source: ./dev-workflow) ──
dev-workflow/
├── .claude-plugin/plugin.json
├── .claude/
│   ├── skills/                  # thin routers: greenfield-setup · tdd-workflow · schema-migrations · testing · workflow-init
│   ├── agents/                  # rubocop-fixer · ruff-fixer · diff-reviewer
│   ├── commands/                # transfer-context
│   ├── hooks/                   # pre-commit-gate.sh (commit gate) · context-guard.sh (auto-compact guard)
│   └── settings.json            # hook registration (drop-in mode)
├── hooks/hooks.json             # hook registration (plugin mode)
├── agent_docs/
│   ├── core/                    # coding_workflow.md (spine) · feature_closeout.md (post-merge) · orchestration.md (advised tools) · quickref.md (10-rule floor)
│   ├── ruby/                    # building_the_project · code_conventions · database_schema · running_tests · toolchain
│   └── python/                  # same five files
└── README.md                    # detailed guide

# ── craft-workflow (source: ./craft-workflow) ──
craft-workflow/
├── .claude-plugin/plugin.json
├── .claude/skills/              # craft-init · craft-iterate · craft-review
├── craft_docs/
│   ├── core/                    # craft_workflow.md (kernel) · orchestration.md (advised skills) · quickref.md (9-rule floor)
│   └── {experience-design,content,research}/   # each pack: brief.md · rubric.md · toolchain.md
└── README.md                    # detailed guide

# ── job-workflow (source: ./job-workflow) ──
job-workflow/
├── .claude-plugin/plugin.json
├── .claude/
│   ├── skills/                  # thin routers: job-intake · job-goals · job-apply
│   └── agents/                  # cv-tailor · cover-letter-writer · application-verifier · interview-briefer
├── job_docs/
│   ├── core/                    # job_workflow.md (kernel) · kb_schema.md · interview_protocol.md · tailoring_method.md · fit_check.md · orchestration.md · quickref.md
│   ├── standards/               # cv_rules · ats_rules · cover_letter_rules · dach_conventions · rendering
│   ├── lifecycle/               # tracking · postmortem · interview_prep · analytics
│   └── templates/               # cv_template.md
└── README.md                    # detailed guide

.claude/settings.json            # this repo's own hooks (context guard for maintainer sessions)
.claude/skills/repo-audit/       # maintainer-only: audits docs/manifests against the real inventory (not shipped)
README.md                        # marketplace overview     CLAUDE.md  # this file
```
- **dev-workflow**: skills detect language by marker file (`Gemfile` / `pyproject.toml`…) and route to the matching pack; enforcement = the pre-commit hook + the fixer agents.
- **craft-workflow**: **no hook, no fixer agents** by design — enforcement is agent-run sign-off gates + the review loop.
- **job-workflow**: **no hook, no fixer agents** by design — enforcement is the `application-verifier` gate + the claim→KB traceability contract. The plugin ships **zero personal data**: the knowledge base it defines lives in the user's own job folder.

## Maintenance conventions
- **Keep the sibling plugins in sync.** They share a design (a `core/` kernel + supporting docs, `orchestration.md` with an availability check, a `quickref.md` floor, thin skill routers). A change to one's structure usually wants a parallel in the others.
- **Don't add a commit hook or fixer agents to craft-workflow or job-workflow** — their quality bar is judgment, carried by agent-run gates and review loops. That asymmetry is intentional.
- **Never commit personal data into job-workflow** (names, employers, salaries, application material). Its docs are generic method; anything candidate-specific belongs in the user's job folder, not the kit. Sweep before committing.
- **Skills are thin pointers**, not content: a skill's `SKILL.md` detects context and routes to the authoritative `agent_docs/`/`craft_docs/` file. Put substance in the docs, not the skill. Path resolution: project-root copy first, else `../../../<docs>/…` relative to the skill dir. (Applies to the *shipped plugins*; maintainer skills in this repo's `.claude/skills/` hold their procedure inline — there is no docs layer for repo maintenance.)
- **Versioning**: bump the affected plugin's `version` in its `plugin.json` on a meaningful change (breaking renames → major; `dev-workflow` is at 3.x, `craft-workflow` and `job-workflow` at 1.x). Bump with a targeted line edit — a JSON load/dump round-trip reformats the manifest. After the bump's PR merges, tag `main` and publish a GitHub release: `<plugin>-v<version>` (e.g. `dev-workflow-v3.3.0`), notes ending with the consumer update commands (`/plugin marketplace update claude-setup`, `/plugin update <plugin>@claude-setup`). `marketplace.json` carries no versions by design — the tag/release is the marketplace-level signal.
- **Git**: feature branch → PR into `main` (never commit to `main`); [Conventional Commits](https://www.conventionalcommits.org), subject ≤ 60 chars; end commit messages with the `Co-Authored-By` trailer.
- When editing a pack doc, update its plugin's README/detail doc and this layout if the structure changed; run the verification checks above before committing.
- **After any structural change** (skill/agent/hook/doc added, renamed, or removed), run the `repo-audit` skill — it mechanizes the sync check and stale-reference sweep above.
