---
name: craft-init
description: Use at the START of a non-code creative deliverable — a design, UI/UX, landing page, user journey, article, marketing or UX copy, SEO content, or a research/analysis task — or when the user says 'design this', 'make a landing page', 'map the user journey', 'write an article', 'write the copy', 'do SEO for', 'research this', or 'investigate this'. Runs discovery, writes a brief, and gets sign-off before any production. NOT for writing or modifying source code (use the dev-workflow tdd-workflow skill for that).
---

Read `craft_docs/core/craft_workflow.md` and follow it from Step 0. Locate it as follows: use `craft_docs/core/craft_workflow.md` in the project root if present (drop-in install); otherwise read `../../../craft_docs/core/craft_workflow.md` relative to this skill's directory (plugin install).

This skill runs the front of the kernel:
1. **Detect the domain** (Step 0): `experience-design`, `content`, or `research` — a task may span two (web work is usually design + content).
2. **Discovery & brief** (Step 1): read `craft_docs/<domain>/brief.md`, run the interview with AskUserQuestion, and write the brief to `craft/<name>.md`. Offer `capture` for a brain-dump intake and `grill-me` to stress-test a thin brief.
3. **Sign-off gate**: present the brief and get explicit approval before producing anything. Annotate with `plannotator` when available.

Before starting, check `craft/` in the project root for an existing brief matching this deliverable — if one exists, load it and resume instead of re-interviewing. After sign-off, hand off to `craft-iterate`.
