# Experience-Design — Acceptance Rubric

These are the "tests" for a design deliverable. Specialize them to the brief in Step 3, and run every dimension in the Step 5 review loop. Built on established frameworks so the pack works with nothing else installed.

## 1. Goal & hierarchy
- [ ] The **primary action** is the single most visually dominant element — unmistakable within 5 seconds.
- [ ] Visual hierarchy (size, weight, contrast, position) matches the priority order in the brief.
- [ ] One primary CTA per surface; secondary actions are visibly subordinate, not competing.
- [ ] Nothing on the surface is there "just because" — every element earns its place against the goal.

## 2. Usability — Nielsen's 10 heuristics
Evaluate against each; flag violations with the heuristic name:
1. Visibility of system status (loading, progress, confirmation feedback)
2. Match between system and the real world (user's language, familiar conventions)
3. User control & freedom (undo, cancel, back — no dead ends)
4. Consistency & standards (within the surface and with platform conventions)
5. Error prevention (constrain inputs, confirm destructive actions)
6. Recognition over recall (visible options, no memorizing across steps)
7. Flexibility & efficiency (accelerators for repeat users where relevant)
8. Aesthetic & minimalist design (no irrelevant or rarely-needed content)
9. Help users recognize, diagnose, recover from errors (plain-language messages + a way out)
10. Help & documentation (available where needed, task-focused)

## 3. Journey coherence
- [ ] The surface makes sense given where the user **arrives from** and where they go **next**.
- [ ] Entry point is discoverable from the surrounding navigation; the exit/next step is clear.
- [ ] Jobs-to-be-Done: the design serves the user's actual job at this moment, not an internal org chart.

## 4. Critical states
- [ ] **Empty** state designed (first-use / no-data — guides the user to the first action, not a blank void).
- [ ] **Loading** state designed (skeleton/progress, not a frozen UI).
- [ ] **Error** state designed (what went wrong, in plain language, + a recovery path).

## 5. Accessibility — WCAG 2.2 AA
- [ ] Text contrast ≥ 4.5:1 (≥ 3:1 for large text and UI components).
- [ ] Every interactive element is keyboard-reachable and has a visible focus state.
- [ ] Touch/click targets ≥ 24×24 CSS px (2.5.8), ideally ≥ 44px for primary mobile actions.
- [ ] Meaning is never carried by color alone; images have alt text; form fields have labels.
- [ ] Motion respects `prefers-reduced-motion`; nothing flashes more than 3×/sec.

## 6. Responsiveness & brand
- [ ] Works at mobile, tablet, desktop widths — primary action stays prominent at every breakpoint.
- [ ] Conforms to the existing brand / design system (tokens, components, spacing scale); no off-system one-offs without a recorded decision.

### Judgment calls
When two directions are both defensible (layout density, a bold vs. safe visual move, a trade-off between brand consistency and emphasis), present them with trade-offs via AskUserQuestion rather than silently choosing.
