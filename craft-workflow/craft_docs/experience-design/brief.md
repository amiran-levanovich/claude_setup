# Experience-Design — Discovery & Brief

Covers UI/visual design, UX flows, user-journey work, and accessibility. Run the kernel's Step 1 with the questions below, then fill the brief template.

## Discovery questions (ask via AskUserQuestion, ≤2 per call)

1. **Surface & scope** — what are we designing? (single screen/section · a full page/landing · a multi-step flow · a journey map · a design-system component). Recommend the smallest surface that delivers the goal.
2. **Audience & context** — who is the user, on what device/channel, in what mindset/moment? (e.g. first-time visitor on mobile vs. returning power user on desktop).
3. **Primary action** — the single most important thing the user should do here. Everything else is secondary.
4. **Entry & exit** — where does the user arrive from, and where should they go next? (the journey context around this surface).
5. **Brand & constraints** — existing brand/design system, tone, must-use components, hard constraints (length, performance, platform). If a design system exists, we conform to it, not reinvent it.
6. **Critical states** — what are the empty, loading, and error states for the key elements?
7. **Success criteria** — how will we know the design works? (conversion on the primary action, task completion, comprehension). Seeds the rubric.

For anything the codebase or existing site can answer (current routes, components, brand tokens), scan first and only ask what you can't infer.

## Brief template (write to `craft/<name>.md`)

```markdown
## Deliverable: <name>
**Domain:** experience-design
**Review pacing:** per-pass | autonomous

### Brief
- Surface & scope:
- Audience & context (device, mindset, moment):
- Primary action (the one thing):
- Journey — arrives from / goes to:
- Brand / design system / constraints:
- Critical states (empty / loading / error):
- Success criteria:

### Plan
- [ ] <atomic piece — e.g. "hero + primary CTA", "social-proof section", "mobile layout", "empty state">

### Decisions
### Dead ends
### Open questions
```

When the surface also carries copy (almost always, for landing/marketing work), pull the **content** pack's brief alongside this one — design and words are decided together, not in sequence.
