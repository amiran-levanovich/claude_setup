# Project Initialization & Greenfield Setup

This playbook governs the phase sequence for initializing a brand-new project or major standalone subsystem from scratch. The one hard gate: no feature code until Phase G4 sign-off is completed.

> Greenfield phases are numbered **G0–G4** to keep them distinct from the daily-workflow Phases 1–4 in `core/coding_workflow.md` — a bare "Phase N" always means the daily workflow.

---

## PHASE G0: DISCOVERY & REQUIREMENTS GATHERING
Before any technical architecture is drafted, you must interactively prompt the user to establish a precise product scope. Extract clear answers for the following vectors:

*   **Functional Scope:** Target user personas, core workflows, and non-negotiable features.
*   **Data Scale:** Estimated volume, expected payload sizes, retention policies, and read/write intensity.
*   **Integrations:** Third-party APIs, authentication providers, webhooks, or external data brokers.
*   **Performance Bounds:** Latency thresholds, expected concurrency, and memory footprints.
*   **Failure Modes:** Edge cases, offline behavior requirements, and network loss patterns.

### Interview mechanics
Run the discovery as a structured interview using the **AskUserQuestion tool** (multi-choice prompts in the CLI), not as a wall of open-ended questions:

*   One vector at a time, at most two questions per tool call — never all five vectors in one message.
*   Give each question 2–4 concrete options with the recommended one first, marked "(Recommended)" and justified in its description. The user can always type a custom answer via "Other".
*   Use free-text prose questions only where options can't be enumerated (e.g., "describe the core workflow").
*   Follow up on answers that change the architecture (e.g., "offline-first" triggers a sync-strategy question) and skip vectors the user's earlier answers already settled.

### Phase G0 Output: Requirements Document
Before advancing to Phase G1, produce `docs/requirements.md` with this structure:

```markdown
# Requirements: <Project Name>
## Functional Scope
- Target personas:
- Core workflows:
- Non-negotiable features:
## Data Scale
- Volume estimate:
- Read/write intensity:
## Integrations
- External APIs:
- Auth providers:
## Performance Bounds
- Latency threshold:
- Concurrency:
## Failure Modes
- Edge cases:
- Offline behaviour:
```

### Plannotator Review (strongly recommended when available)
Before presenting the document to the user, check whether the **Plannotator** plugin is available (it appears as `plannotator-annotate` in your skill list):

*   **If Plannotator is installed:** use the review loop below — it is the preferred review channel because annotations are precise and per-section.
*   **If Plannotator is not installed:** note the absence in your response and run the same review iteratively over the inline markdown document instead.

#### Iterative Review Loop
Repeat until the user returns no new annotations:

1. Invoke `/plannotator-annotate docs/requirements.md`.
2. Receive the user's annotations.
3. If there are **no annotations** — exit the loop and proceed to sign-off.
4. If there **are annotations** — address every one of them: fill gaps, resolve ambiguities, and update `docs/requirements.md`.
5. Go back to step 1 with the updated file.

Do not exit the loop early. Every round must be clean (zero annotations) before moving on.

Present the final `docs/requirements.md` to the user and receive explicit sign-off before continuing.

---

## PHASE G1: HIGH-LEVEL ARCHITECTURE & MODELING
Once requirements are locked, map out the technical domain before touching any setup files.

### 1. Visual Architecture
*   Generate a structural system diagram using **Mermaid**.
*   **Mandatory:** Create the docs directory if it does not exist (`mkdir -p docs/`), then save the final version of this diagram at `docs/architecture.md` and commit it to the repository.

### 2. Data Modeling & Core Associations
Establish your structural data layer before writing migrations:
*   **Tables & Schemas:** Define table names, accurate column names, and exact database data types.
*   **Relationships:** Map all active associations (`has_many`, `belongs_to`, `through:`, etc.).
*   **Constraints:** Enforce constraints at the database level (`null: false`, `unique: true`, cascades) to safeguard structural integrity.

### 3. UX & Interface Map (optional — ask the user first)
A data model and an architecture diagram say nothing about what the user actually sees. Before locking the design, ask the user — via the **AskUserQuestion tool** — whether they want a high-level UX pass for this project. Recommend it for any app with a human-facing UI; skip it for headless APIs, background workers, or CLI-only tools.

If the user opts in, establish the following at a high level (this is interface mapping, not pixel design):
*   **Root page:** what loads at `/` — landing, dashboard, or sign-in — and for which persona.
*   **Primary navigation:** the top-level sections a user can reach, and how they move between them.
*   **Key screens:** the handful of screens that carry the core workflows from `docs/requirements.md`.
*   **Core user flows:** the click-path for each non-negotiable feature (e.g. sign-up → onboarding → first action).
*   **Critical states:** the empty, loading, and error states for the key screens.

Capture the outcome in `docs/ux.md` as a bulleted map or a **Mermaid** flow diagram — no visual mockups. When **Plannotator** is available, run it through `/plannotator-annotate docs/ux.md` for review like the other Phase artifacts. If the user opts out, note the absence and move on — nothing downstream blocks on this document.

---

## PHASE G2: STRATEGIC PLANNING & TO-DO ENGINES

### 1. Roadmap Breakdown
*   Deconstruct the entire setup roadmap into explicit, isolated sub-tasks.
*   When the **Plannotator** plugin is available, run the breakdown through `/plannotator-annotate` so the user can review and annotate it per-task before execution. Otherwise, present it as an inline markdown task list for approval.

### 2. Strict Execution To-Do Lists
*   Compile a comprehensive, linear To-Do List for the project setup.
*   Follow this list sequentially. Mark tasks completed as you progress. Do not multi-task or deviate.

---

## PHASE G3: SCAFFOLD, DEPENDENCY AUDIT & CORE TOOLING

### 1. Scaffold the application
Turn the approved design into a running skeleton — this is setup, not feature code, so it does not violate the Phase G4 gate:

1. `git init -b main` if the repo doesn't exist yet. The pre-commit gate exempts a repo with zero commits, so the initial scaffold commit lands on `main`; every commit after it follows the branch rules in `core/coding_workflow.md`.
2. `rails new . --database=postgresql` with the flags the requirements imply (`--api` for headless services, `--skip-test` since RSpec replaces Minitest).
3. Install the test stack: add `rspec-rails` (+ `factory_bot_rails`, `faker`, `capybara`/`selenium-webdriver` for system specs) to the Gemfile and run `bundle exec rails generate rspec:install`.
4. Write `.rubocop.yml` (requires `rubocop-rails`, `NewCops: enable`) and the Bullet config (`Bullet.enable` in development and test, `Bullet.raise = true` in test).
5. Commit the scaffold, then verify the gate is live: the linter runs (`bundle exec rubocop --version`) and a trial commit on `main` is now blocked.

### 2. Core tooling
Every Ruby on Rails project initialized in this environment must be configured with this core safety and performance stack from Day 1:

| Library / Gem | Gemfile Pin | Operational Mandate |
| :--- | :--- | :--- |
| **`bullet`** | `~> 8` | Active memory profiling. Detects and kills N+1 queries and lazy/unused eager loading instantly. |
| **`brakeman`** | `~> 7` | Static analysis security scanner. Audits the codebase for vulnerabilities, SQL injection, and XSS risks. |
| **`rubocop`** | `~> 1` | Strict code layout and style enforcement aligned with Ruby community best practices. |
| **`rubocop-rails`** | `~> 2` | Rails-specific cops for controllers, models, and migrations. |
| **`strong_migrations`** | `~> 2` | Catches hazardous database migration patterns that cause table-locking or downtime. |

> Pins use pessimistic `~>` on the current major version. Run `bundle outdated` at initialization to confirm these are still the latest majors.

---

## PHASE G4: FINAL PRESENTATION & SIGN-OFF
Compile the architectural diagrams, database schema maps, the UX map (when one was produced in Phase G1), task roadmaps, and core tooling selections into a unified **Final Presentation**.

> ❗ **The Execution Gate:** Present this summary to the user. **Zero feature coding is allowed** until the user reviews this presentation and gives explicit authorization to begin development. 
> 
> Once authorized, close this document and transition entirely to the tracking rules outlined in `agent_docs/core/coding_workflow.md`.