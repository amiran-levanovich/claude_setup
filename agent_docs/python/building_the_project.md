# Python Project Initialization & Greenfield Setup

This playbook governs the phase sequence for initializing a brand-new Python project or major standalone subsystem from scratch. The one hard gate: no feature code until Phase 4 sign-off is completed.

---

## PHASE 0: DISCOVERY & REQUIREMENTS GATHERING
Before any technical architecture is drafted, interactively prompt the user to establish a precise product scope. Extract clear answers for:

*   **Functional Scope:** Target user personas, core workflows, and non-negotiable features.
*   **Data Scale:** Estimated volume, payload sizes, retention policies, read/write intensity.
*   **Integrations:** Third-party APIs, authentication providers, webhooks, external data brokers.
*   **Performance Bounds:** Latency thresholds, expected concurrency, memory footprints.
*   **Failure Modes:** Edge cases, offline behavior requirements, network loss patterns.

### Interview mechanics
Run discovery as a structured interview using the **AskUserQuestion tool**, not a wall of open-ended questions:

*   One vector at a time, at most two questions per tool call — never all five vectors in one message.
*   Give each question 2–4 concrete options, recommended one first, marked "(Recommended)" and justified. The user can always type "Other".
*   Free-text prose questions only where options can't be enumerated (e.g., "describe the core workflow").
*   Follow up on answers that change the architecture; skip vectors earlier answers already settled.

### Phase 0 Output: Requirements Document
Before advancing, produce `docs/requirements.md`:

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
Before presenting the document, check whether the **Plannotator** plugin is available (`plannotator-annotate` in your skill list):

*   **If installed:** use the iterative review loop — preferred because annotations are precise and per-section.
*   **If not installed:** note the absence and run the same review iteratively over the inline markdown.

#### Iterative Review Loop
Repeat until the user returns no new annotations:
1. Invoke `/plannotator-annotate docs/requirements.md`.
2. Receive the user's annotations.
3. **No annotations** — exit the loop and proceed to sign-off.
4. **Annotations exist** — address every one, update `docs/requirements.md`.
5. Go back to step 1 with the updated file.

Present the final `docs/requirements.md` and receive explicit sign-off before continuing.

---

## PHASE 1: STACK SELECTION, ARCHITECTURE & MODELING

### 1. Framework Selection (Python greenfield)
Choose the web framework via the **AskUserQuestion tool** — two options for now, recommend based on the Phase 0 answers:

*   **Django** (Recommended for) — apps that want batteries included: built-in ORM, migrations, admin, auth, and server-rendered or DRF API surfaces. Best when the data model is relational and the team wants convention over assembly.
*   **FastAPI** — async-first JSON APIs and services: explicit, lightweight, Pydantic-validated, typically paired with SQLAlchemy + Alembic. Best for high-concurrency APIs, microservices, or ML-serving endpoints.

Record the choice — it determines the ORM and migration tool in `database_schema.md` and the test client in `running_tests.md`. Add it to the project `CLAUDE.md` `## Project Identity` section.

### 2. Visual Architecture
*   Generate a structural system diagram using **Mermaid**.
*   **Mandatory:** `mkdir -p docs/`, save the diagram at `docs/architecture.md`, and commit it.

### 3. Data Modeling & Core Associations
Establish the structural data layer before writing migrations:
*   **Tables & Schemas:** table names, accurate column names, exact database data types.
*   **Relationships:** map all associations (one-to-many, many-to-many, FKs) in ORM terms.
*   **Constraints:** enforce at the database level (`null=False`, unique constraints, on-delete cascades) per `database_schema.md`.

### 4. UX & Interface Map (optional — ask the user first)
A data model says nothing about what the user sees. Before locking the design, ask the user — via the **AskUserQuestion tool** — whether they want a high-level UX pass. Recommend it for any human-facing UI; skip it for headless APIs, workers, or CLI tools.

If they opt in, establish at a high level (interface mapping, not pixel design): root page, primary navigation, key screens carrying the core workflows, core user flows, and the empty/loading/error states. Capture the outcome in `docs/ux.md` as a bulleted map or **Mermaid** flow — no mockups. Run it through `/plannotator-annotate docs/ux.md` when available. If they opt out, note it and move on.

---

## PHASE 2: STRATEGIC PLANNING & TO-DO ENGINES

### 1. Roadmap Breakdown
*   Deconstruct the setup roadmap into explicit, isolated sub-tasks.
*   When **Plannotator** is available, run the breakdown through `/plannotator-annotate` for per-task review. Otherwise present an inline markdown task list for approval.

### 2. Strict Execution To-Do Lists
*   Compile a comprehensive, linear setup To-Do List. Follow it sequentially, marking tasks complete. Do not multi-task or deviate.

---

## PHASE 3: SCAFFOLD, DEPENDENCY AUDIT & CORE TOOLING

### 1. Scaffold the application
Turn the approved design into a running skeleton — this is setup, not feature code, so it does not violate the Phase 4 gate:

1. `git init -b main` if the repo doesn't exist yet. The pre-commit gate exempts a repo with zero commits, so the initial scaffold commit lands on `main`; every commit after it follows the branch rules in `core/coding_workflow.md`.
2. `uv init` (or the chosen manager's equivalent), then scaffold the Phase 1 framework: Django — `uv add django` + `django-admin startproject`; FastAPI — `uv add fastapi uvicorn sqlalchemy alembic` + the app module and `alembic init`.
3. Add the dev/test group from the table below (`uv add --dev ruff bandit pytest pytest-cov ...`) and the framework test integration (`pytest-django` / `httpx`).
4. Configure `[tool.ruff]` (lint + format) and `[tool.bandit]` (test-dir excludes) in `pyproject.toml`.
5. Commit the scaffold, then verify the gate is live: `ruff --version` runs via the manager, and a trial commit on `main` is now blocked.

### 2. Core tooling
Every Python project initialized in this environment is configured with this core stack from Day 1 (in the `dev`/`test` dependency group of `pyproject.toml`):

| Package | Role | Enforced by |
| :--- | :--- | :--- |
| **`ruff`** | Lint + format (replaces black/flake8/isort) | Hook — blocks `git commit` on offenses or unformatted code |
| **`bandit`** | Static security analysis | Hook — blocks `git commit` on issues |
| **`pytest`** + `pytest-cov` | Test runner + coverage | Agent — green suite before implementation commits |
| Django: `pytest-django` · FastAPI: `httpx` | Framework test integration | Agent |
| `factory_boy` + `faker` | Test data factories | Agent |
| `respx` / `responses` | HTTP mocking | Agent — total mocking mandate |

**Dependency manager:** prefer **uv** (`uv init`, `uv add`, `uv.lock`); Poetry and pip+venv are acceptable — see `toolchain.md` for detection. **mypy** is optional and **not** gated; offer it as a project choice.

> Pin packages in `pyproject.toml`; let the lockfile freeze exact versions. Run the manager's `outdated` check at init.

---

## PHASE 4: FINAL PRESENTATION & SIGN-OFF
Compile the architecture diagram, schema maps, the UX map (when produced), task roadmaps, framework choice, and core tooling into a unified **Final Presentation**.

> ❗ **The Execution Gate:** Present this summary to the user. **Zero feature coding is allowed** until the user reviews it and gives explicit authorization to begin development.
>
> Once authorized, close this document and transition entirely to the tracking rules outlined in `agent_docs/core/coding_workflow.md`.
