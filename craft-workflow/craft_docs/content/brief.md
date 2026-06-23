# Content — Discovery & Brief

Covers long-form writing (articles, docs, proposals), marketing/landing copy, UX microcopy, and SEO content. These share a spine but differ in sub-mode — establish the sub-mode first.

## Sub-mode (ask first)
- **long-form** — articles, blog posts, documentation, proposals, essays.
- **marketing/landing** — homepage, landing, pricing, feature pages (conversion-oriented).
- **ux-microcopy** — interface copy: buttons, errors, empty states, tooltips, notifications.
- **seo** — search-intent-driven content meant to rank (often overlaps long-form/marketing).

A piece can be more than one (a landing page is marketing + seo). Pull the relevant rubric sections accordingly.

## Discovery questions (AskUserQuestion, ≤2 per call)
1. **Audience & intent** — who reads this, what do they already know, what do they want when they arrive?
2. **Goal / desired action** — what should the reader think, feel, or do after reading?
3. **Voice & tone** — existing brand voice/style guide? Formal vs. conversational? Any words to avoid?
4. **Format & length** — channel, length target, structure constraints (must-include sections, CTAs).
5. **SEO (if applicable)** — target query/topic and search intent (informational / commercial / transactional); primary keyword + a few secondary terms.
6. **Source material** — existing drafts, product facts, research to ground claims (never invent facts; ask for sources).
7. **Success criteria** — ranking, conversion, comprehension, sign-ups — seeds the rubric.

## Brief template (write to `craft/<name>.md`)

```markdown
## Deliverable: <name>
**Domain:** content  ·  **Sub-mode:** long-form | marketing | ux-microcopy | seo
**Review pacing:** per-pass | autonomous

### Brief
- Audience & intent:
- Goal / desired action:
- Voice & tone (+ words to avoid):
- Format & length / structure:
- SEO: target query · search intent · primary + secondary keywords:
- Source material / facts to ground claims:
- Success criteria:

### Plan
- [ ] <atomic piece — e.g. "outline", "hero headline + subhead", "section: how it works", "meta title + description">

### Decisions
### Dead ends
### Open questions
```

**Outline before prose.** For anything longer than a few lines, the first plan item is an approved outline — get sign-off on structure before drafting full copy.
