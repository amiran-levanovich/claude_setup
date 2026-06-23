---
name: craft-review
description: Use to REVIEW or finish a non-code deliverable (design, UI/UX, landing page, article, marketing/UX copy, SEO content, research report) before calling it done — a full critique-and-fix loop against the domain rubric. Triggers on 'review this design/copy/report', 'critique this', 'is this good enough', 'is this done', 'polish this', 'finalize this'. NOT for source code review (use dev-workflow's review skills).
---

Read `craft_docs/core/craft_workflow.md` and run Step 5 (the completion review loop). Locate it: use `craft_docs/core/craft_workflow.md` in the project root if present (drop-in); otherwise `../../../craft_docs/core/craft_workflow.md` relative to this skill's directory (plugin install).

Non-code work has no deterministic gate, so this loop carries the entire quality bar. Detect the domain, then repeat until a clean round:

1. **Review** the whole deliverable against every dimension in `craft_docs/<domain>/rubric.md`. Prefer `plannotator` (annotate the rendered design/draft) and any critique skill named in `craft_docs/<domain>/toolchain.md`; otherwise critique manually.
2. **No findings?** Done — present the deliverable and the Definition of Done checklist from `craft_docs/<domain>/toolchain.md`.
3. **Findings?** Report them first (prioritized: location, problem, proposed fix), then fix. Ask via AskUserQuestion on genuine judgment calls. Record non-obvious decisions in `craft/<name>.md`.
4. **Re-review** — a fix in one dimension can break another, so the whole pass runs again.

Do not declare done on a round that still has open findings. Every dimension must come back clean in the same round.
