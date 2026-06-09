# Project Initialization & Greenfield Setup

This playbook governs the non-negotiable phase sequence required to initialize a brand-new project or major standalone subsystem from scratch. Coding is strictly forbidden until Phase 4 sign-off is completed.

---

## PHASE 0: DISCOVERY & REQUIREMENTS GATHERING
Before any technical architecture is drafted, you must interactively prompt the user to establish a precise product scope. Extract clear answers for the following vectors:

*   **Functional Scope:** Target user personas, core workflows, and non-negotiable features.
*   **Data Scale:** Estimated volume, expected payload sizes, retention policies, and read/write intensity.
*   **Integrations:** Third-party APIs, authentication providers, webhooks, or external data brokers.
*   **Performance Bounds:** Latency thresholds, expected concurrency, and memory footprints.
*   **Failure Modes:** Edge cases, offline behavior requirements, and network loss patterns.

### Phase 0 Output: Requirements Document
Before advancing to Phase 1, produce `docs/requirements.md` with this structure:

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

### Plannotator Review (mandatory if installed)
Before presenting the document to the user, check whether the **Plannotator** plugin is available (it appears as `plannotator-annotate` in your skill list):

*   **If Plannotator is installed:** enter the review loop below. This step is **not optional**; skipping it when the plugin is present is a workflow violation.
*   **If Plannotator is not installed:** note the absence in your response and continue with the inline markdown document.

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

## PHASE 1: HIGH-LEVEL ARCHITECTURE & MODELING
Once requirements are locked, map out the technical domain before touching any setup files.

### 1. Visual Architecture
*   Generate a structural system diagram using **Mermaid**.
*   **Mandatory:** Create the docs directory if it does not exist (`mkdir -p docs/`), then save the final version of this diagram at `docs/architecture.md` and commit it to the repository.

### 2. Data Modeling & Core Associations
Establish your structural data layer before writing migrations:
*   **Tables & Schemas:** Define table names, accurate column names, and exact database data types.
*   **Relationships:** Map all active associations (`has_many`, `belongs_to`, `through:`, etc.).
*   **Constraints:** Enforce constraints at the database level (`null: false`, `unique: true`, cascades) to safeguard structural integrity.

---

## PHASE 2: STRATEGIC PLANNING & TO-DO ENGINES

### 1. Plannotate Breakdown
*   Deconstruct the entire setup roadmap into explicit, isolated sub-tasks.
*   Every initialization task must be systematically mapped and estimated using the **plannotate** plugin.

### 2. Strict Execution To-Do Lists
*   Compile a comprehensive, linear To-Do List for the project setup.
*   Follow this list sequentially. Mark tasks completed as you progress. Do not multi-task or deviate.

---

## PHASE 3: DEPENDENCY AUDIT & CORE TOOLING
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

## PHASE 4: FINAL PRESENTATION & SIGN-OFF
Compile the architectural diagrams, database schema maps, plannotate roadmaps, and core tooling selections into a unified **Final Presentation**.

> ❗ **The Execution Gate:** Present this summary to the user. **Zero feature coding is allowed** until the user reviews this presentation and gives explicit authorization to begin development. 
> 
> Once authorized, close this document and transition entirely to the tracking rules outlined in `agent_docs/coding_workflow.md`.