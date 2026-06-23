---
name: craft-init
description: Use at the START of a non-code creative deliverable — a design, UI/UX, landing page, user journey, article, marketing or UX copy, SEO content, or a research/analysis task — or when the user says 'design this', 'make a landing page', 'map the user journey', 'write an article', 'write the copy', 'do SEO for', 'research this', or 'investigate this'. Runs discovery, writes a brief, and gets sign-off before any production. NOT for writing or modifying source code (use the dev-workflow tdd-workflow skill for that).
---

Read `craft_docs/core/craft_workflow.md` and follow it from Step 0. Locate it as follows: use `craft_docs/core/craft_workflow.md` in the project root if present (drop-in install); otherwise read `../../../craft_docs/core/craft_workflow.md` relative to this skill's directory (plugin install).

This skill runs the front of the kernel:
1. **Detect the domain** (Step 0): `experience-design`, `content`, or `research` — a task may span two (web work is usually design + content).
2. **Orchestration check**: read `craft_docs/core/orchestration.md` and run its availability check — inspect the skills/tools actually available to you this session, and report a compact table of which *advised* skills (for the detected domain) are present vs missing, with the one-line rationale and install pointer for any that are absent. This is **informational and never blocks** — every pack is self-sufficient via its baked-in rubric. Only offer to pause if a strongly-advised engine (`marketingskills`, `deep-research`) is missing and the user may want it first.
3. **Discovery & brief** (Step 1): read `craft_docs/<domain>/brief.md`, run the interview with AskUserQuestion, and write the brief to `craft/<name>.md`. Use a brain-dump intake skill (e.g. `capture`) if available, and offer a brief stress-test (e.g. `grill-me`) for a thin brief.
4. **Sign-off gate**: present the brief and get explicit approval before producing anything. Annotate with an annotation-review skill (e.g. `plannotator`) when available.

Before starting, check `craft/` in the project root for an existing brief matching this deliverable — if one exists, load it and resume instead of re-interviewing. After sign-off, hand off to `craft-iterate`.
