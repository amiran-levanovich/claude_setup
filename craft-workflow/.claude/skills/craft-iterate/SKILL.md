---
name: craft-iterate
description: Use while PRODUCING a non-code deliverable (design, UI/UX, landing page, article, marketing/UX copy, SEO content, research report) once a brief exists — to draft, design, or build the next piece and iterate on it. Triggers on 'draft the next section', 'produce this', 'design the hero', 'write this section', 'iterate on the copy/design', 'do the next research pass'. NOT for source code (use dev-workflow's tdd-workflow).
---

Read `craft_docs/core/craft_workflow.md` and follow Steps 2–4. Locate it: use `craft_docs/core/craft_workflow.md` in the project root if present (drop-in); otherwise `../../../craft_docs/core/craft_workflow.md` relative to this skill's directory (plugin install). Those two locations are the only ones: if neither resolves, report the broken install and stop — never search the filesystem for `craft_docs`.

This skill runs the production loop:
1. **Plan as a living doc** (Step 2): if not already done, decompose the deliverable into atomic pieces in `craft/<name>.md` and choose a review pacing (per-pass / autonomous).
2. **Criteria-first** (Step 3): before producing each piece, write its acceptance rubric, pulled from `craft_docs/<domain>/rubric.md` and specialized to the brief. The rubric is the test — no production before it exists.
3. **Produce → check → iterate** (Step 4): produce the piece (orchestrating the production skills named in `craft_docs/<domain>/toolchain.md`), check it against its rubric yourself, fix every miss, then present. Update the living doc after each piece.

If no brief exists yet, stop and run `craft-init` first. When the whole deliverable is drafted, hand off to `craft-review`.
