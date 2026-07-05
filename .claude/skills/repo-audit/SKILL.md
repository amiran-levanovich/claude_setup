---
name: repo-audit
description: "Maintainer-only audit for the claude_setup repo: verify that README.md, CLAUDE.md, both plugin READMEs, and the marketplace/plugin manifests are fully aligned with the actual skill/agent/hook/doc inventory of both plugins. Use after adding, renaming, or removing any skill, agent, command, hook, or pack doc; before committing a structural change; or when the user says 'repo audit', 'audit the repo', 'check the repo is in sync', or 'stale reference sweep'. Not shipped with either plugin — it maintains the kit itself."
---

# repo-audit — keep claude_setup's docs true to its file tree

**Source of truth:** the file tree under `dev-workflow/` and `craft-workflow/`. Every
document *derives* from it. Never assume you know the inventory — read it fresh each run.

## Phase 1 — Build the live inventory

```bash
python3 - <<'EOF'
import json
m = json.load(open('.claude-plugin/marketplace.json'))
print('marketplace plugins:', [(p['name'], p['source']) for p in m['plugins']])
for d in ('dev-workflow', 'craft-workflow'):
    p = json.load(open(f'{d}/.claude-plugin/plugin.json'))
    print(d, 'version:', p['version'], '| declared:', {k: p[k] for k in ('skills','commands','agents','hooks') if k in p})
EOF
find dev-workflow/.claude craft-workflow/.claude -name "SKILL.md" -o -name "*.md" -path "*agents*" -o -name "*.md" -path "*commands*" | sort
find dev-workflow/.claude/hooks dev-workflow/hooks -type f | sort
find dev-workflow/agent_docs craft-workflow/craft_docs -name "*.md" | sort
ls .claude/skills/
```

Record per plugin: skills (dir names), agents, commands, hooks, doc-pack files, version.

## Phase 2 — Audit each document against the inventory

Log every finding as one of:

```
[GAP]    file — inventory item missing from the document
[STALE]  file — document names something that no longer exists
[WRONG]  file — a relationship or path stated incorrectly (route target, version, layout)
```

Audit, in order:
1. **`CLAUDE.md`** — the Layout block must list every real directory and every skill/agent/
   hook by its current name; the plugin version majors ("dev-workflow is at 3.x…") match
   the manifests.
2. **`README.md`** (marketplace overview) — both plugins present, install commands valid.
3. **`dev-workflow/README.md`** — the "What's inside" tree, the skills routing table, the
   hook description, and the mandatory-tooling tables match reality (including gate
   behavior claims vs `pre-commit-gate.sh`).
4. **`craft-workflow/README.md`** — same, for packs and skills.
5. **Manifests** — every path in `marketplace.json` and both `plugin.json`s resolves to an
   existing file/dir.
6. **Cross-plugin symmetry** — the two plugins share a design (kernel + packs +
   `toolchain.md` + an `*-init` skill + quickref floor + close-out/lessons conventions).
   A structural element present in one and absent in the other is a finding unless
   CLAUDE.md documents the asymmetry (e.g. craft has no hook/fixers, by design).
7. **Skill routing** — each thin skill's `SKILL.md` points at doc files that exist, using
   the documented path resolution (project root first, then plugin-relative).

Present the consolidated findings report before changing anything.

## Phase 3 — Fix

Apply agreed fixes, one edit pass per file. Then verify:

```bash
# JSON still valid
python3 -c "import json; [json.load(open(f)) for f in ('.claude-plugin/marketplace.json','dev-workflow/.claude-plugin/plugin.json','craft-workflow/.claude-plugin/plugin.json','dev-workflow/hooks/hooks.json')]; print('JSON_OK')"
# shell still valid
bash -n dev-workflow/.claude/hooks/pre-commit-gate.sh && bash -n dev-workflow/.claude/hooks/context-guard.sh && echo BASH_OK
# stale-name sweep: grep every skill/agent/doc name you renamed or removed this session
grep -rn "<old-name>" README.md CLAUDE.md dev-workflow craft-workflow --include="*.md" --include="*.json"
```

A clean run = JSON_OK + BASH_OK + the stale-name grep returns nothing. If any check
fails, fix and re-run before declaring done.

## What good looks like
- Every skill, agent, command, hook, and pack doc appears in its plugin's README and in
  CLAUDE.md's layout, under its current name — and nothing extra does.
- Manifest paths all resolve; versions in prose match `plugin.json`.
- The two plugins are symmetric except where CLAUDE.md declares the asymmetry deliberate.
