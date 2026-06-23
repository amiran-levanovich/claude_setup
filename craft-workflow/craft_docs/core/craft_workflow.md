# The Craft Workflow — a domain-neutral method for non-code deliverables

This runbook is the **domain-agnostic kernel** for producing non-code work — a design, a landing page, an article, a research report — with the same discipline the code workflow brings to software. It is the sibling of the `dev-workflow` plugin's `coding_workflow.md`: same spine (understand → plan → criteria-first → produce → review loop), with the code-specific machinery (git branching, commit gates, test suites) replaced by **agent-enforced gates** because non-code quality is a judgment, not a shell check.

> **The one rule that carries over unchanged:** define what "good" looks like *before* you produce. In code that is a failing test; here it is an explicit **acceptance rubric**. Producing before the rubric exists is the same mistake as writing implementation before the test.

---

## STEP 0 — DETECT THE DOMAIN
There is no marker file here; detect the **task type** from the request and route to the matching pack:

| The task is about… | `<domain>` | Pack |
| :--- | :--- | :--- |
| UI, visual design, layouts, user journeys, UX flows, accessibility | `experience-design` | `craft_docs/experience-design/` |
| Writing — long-form, marketing/landing copy, UX microcopy, SEO content | `content` | `craft_docs/content/` |
| Investigating a question, gathering evidence, synthesizing findings, reports | `research` | `craft_docs/research/` |

If the task spans two domains (e.g. "design and write a landing page"), run the kernel once and pull the brief/rubric from **both** packs — most web work is `experience-design` + `content` together. If the request fits none, run the kernel with a brief and rubric you construct from first principles, and tell the user no specialized pack applies.

Each pack supplies three files: `brief.md` (discovery questions + brief template), `rubric.md` (the acceptance criteria — your "tests"), and `toolchain.md` (which skills to orchestrate, and the definition of done).

---

## STEP 1 — DISCOVERY & BRIEF (before any production)
You cannot judge a deliverable without knowing who it's for and what it must achieve. Interview the user first, then write a brief, then get sign-off.

### Interview mechanics
Use the **AskUserQuestion tool**, not a wall of open questions:
*   One topic at a time, at most two questions per call.
*   2–4 concrete options each, recommended one first and justified; free-text only where options can't be enumerated.
*   Pull the domain-specific question set from `<domain>/brief.md`.
*   If the user hands you a brain-dump, run it through the **`capture`** skill first to structure it, then fill the brief from that.

### The brief
Write `craft/<deliverable-kebab-name>.md` (create the `craft/` directory if needed) using the template in `<domain>/brief.md`. Every brief, regardless of domain, pins down:
*   **Audience** — who it's for, their context and intent.
*   **Goal / primary action** — the single most important outcome.
*   **Constraints** — brand, voice, length, channel, deadline, must-include / must-avoid.
*   **Success criteria** — how we'll know it worked (this seeds the rubric in Step 3).

### Sign-off gate
Present the brief and get **explicit sign-off before producing anything**. This is the equivalent of the greenfield Phase 4 execution gate — zero production until the brief is approved. To pressure-test a thin or hand-wavy brief before sign-off, offer the **`grill-me`** skill. When `plannotator` is available, annotate the brief with it for precise, per-section review.

---

## STEP 2 — PLAN AS A RESUMABLE LIVING DOC
The brief file is **working state, not documentation** — it lives only while the deliverable is in flight. Extend it with a plan and keep it current:

```
## Deliverable: <name>
**Domain:** experience-design | content | research
**Review pacing:** per-pass | autonomous

### Brief
- Audience / goal / constraints / success criteria  (from Step 1)

### Plan
- [ ] <atomic piece of the deliverable — e.g. "hero section", "methodology section", "competitor scan">
- [ ] ...

### Decisions
- <decision and why — appended as you go>

### Dead ends
- <approach that failed and why — so it isn't retried>

### Open questions
- <unresolved item, and what it blocks>
```

Decompose the deliverable into atomic pieces (a landing page → hero, value props, social proof, CTA; a report → each research question). Keep the doc tight — one line per entry; consolidate a section when it passes ~10 entries. Present the plan and ask the user to pick a **review pacing** (AskUserQuestion, per-pass recommended): *per-pass* (pause after each piece) or *autonomous* (produce the whole thing, present at the end — but stop immediately on any significant deviation from the approved brief). On close-out, promote anything durable (a brand rule, a voice guide) to the project's `CLAUDE.md`, then delete the brief — git history preserves it if the work is in a repo.

---

## STEP 3 — CRITERIA-FIRST (the rubric is your test)
Before producing a piece, write down the **acceptance rubric** it must satisfy — pulled from `<domain>/rubric.md` and specialized to this brief. This is the non-code analog of writing the failing test first.

*   The rubric is concrete and checkable: not "good copy" but "value proposition legible in 5 seconds, one primary CTA, reading level ≤ grade 8."
*   Record the rubric for each piece in the brief doc so a later session inherits the same bar.
*   If the brief can't produce a checkable rubric for a piece, the brief is too vague — go back to Step 1 for that piece.

---

## STEP 4 — PRODUCE → CHECK → ITERATE
For each piece on the plan:

1. **Produce** the piece — directly, or by orchestrating the production skill named in `<domain>/toolchain.md` (e.g. `frontend-design` for UI, `marketingskills` copywriting for landing copy, `deep-research` for a research pass).
2. **Check** it against the piece's rubric (Step 3) yourself, before showing the user. Fix every miss.
3. **Present** with a one-line note on how it meets the rubric; be verbose only about trade-offs or genuine judgment calls (surface those via AskUserQuestion, recommended option first).
4. **Update the living doc** — mark the piece done, append decisions/dead-ends/resolved questions.

Never present a piece you know fails its own rubric. Do not advance to the next piece until the current one passes (in per-pass mode, after the user's nod).

---

## STEP 5 — COMPLETION REVIEW LOOP (before "done")
Code has a deterministic pre-commit gate; non-code has none — so the **entire** quality bar lives here, in an agent-run loop over the whole deliverable. This is the same review→report→fix→re-review loop as the code workflow's Phase 4, run against the domain's full rubric.

Repeat until a clean round:

1. **Review.** Run every dimension in `<domain>/rubric.md` over the whole deliverable. Prefer a dedicated review skill when present (`plannotator` for visual/written annotation; the domain's critique skill in `toolchain.md`); otherwise critique manually against the rubric.
2. **No findings?** Done — present the final deliverable and the definition-of-done checklist from `<domain>/toolchain.md`.
3. **Findings?** **Report them first** — a prioritized list (location, the problem, the proposed fix). Don't start editing before reporting.
4. **Fix.** Resolve each finding. For a genuine judgment call (two valid directions, a brand trade-off), ask via AskUserQuestion before deciding. Record non-obvious decisions in the living doc.
5. **Re-review.** Go back to step 1 — a fix in one dimension can break another, so the whole pass runs again.

Do not declare done on a round that still has open findings. Every dimension must come back clean in the **same** round.

---

## NOTES
*   **No commit hook.** Unlike `dev-workflow`, this plugin ships no PreToolUse gate — there is nothing deterministic to check. The gates above (sign-off, criteria-first, the review loop) are yours to enforce.
*   **Git hygiene, when the deliverable lives in a repo.** If the work is version-controlled, the code workflow's hygiene still applies in spirit: work on a feature branch, never commit straight to `main`, use clear messages. Otherwise it doesn't apply.
*   **Orchestrate, don't reinvent.** Every pack defers production and critique to existing skills where they exist (see each `toolchain.md`). The kernel supplies the method; the skills supply the craft.
