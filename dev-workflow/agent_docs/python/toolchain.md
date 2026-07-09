# Python Toolchain Bindings

This file is the single place that maps the **roles** referenced by `core/coding_workflow.md` to the concrete tools used in a Python project. When the spine says "the linter" or "the security scanner," it means the tool named here.

> **Framework:** this pack supports **Django** and **FastAPI**. Where a binding is framework-specific (ORM, migrations, N+1 check), it is marked. The linter/formatter/security/test roles are identical across both.

## Role → tool map

| Role (in the spine)        | Tool                                      | Invocation                                                                                                                                                                                                                        |
| :------------------------- | :---------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Dependency manager         | **uv** (preferred) / **Poetry** / **pip** | detect by lockfile — see below                                                                                                                                                                                                    |
| Linter                     | **Ruff**                                  | `ruff check .` · auto-fix: `ruff check --fix .`                                                                                                                                                                                   |
| Formatter                  | **Ruff formatter**                        | `ruff format --check .` · apply: `ruff format .`                                                                                                                                                                                  |
| Security scanner           | **Bandit**                                | `bandit -q -r .` (full sweep) / `bandit -q <files>` (the gate's changed-files form) — with a `[tool.bandit]` section it uses that config; on a full sweep add `-x ./.venv,./venv,./node_modules` so dependency code isn't scanned |
| N+1 / performance detector | query-count assertions                    | Django: `django_assert_num_queries`; SQLAlchemy: query-count fixture — see `running_tests.md`                                                                                                                                     |
| Test runner                | **pytest**                                | `pytest` (see `running_tests.md`)                                                                                                                                                                                                 |
| Fixer sub-agent            | **`ruff-fixer`**                          | invoke after `ruff check --fix` leaves residual offenses                                                                                                                                                                          |
| Review sub-agent           | **`diff-reviewer`**                       | Phase 4 (no review skill installed): dimension `all` in one invocation for small diffs and confirmation passes; one invocation per dimension for large diffs                                                                      |
| Migration safety           | manual review + framework tooling         | Django migrations / Alembic — see `database_schema.md`                                                                                                                                                                            |

Ruff fills **both** the linter role (replacing flake8/isort/pyupgrade/etc.) and the formatter role (replacing Black). The spine's "formatter check" maps to `ruff format --check .`.

> **mypy is opt-in, not gated.** Static typing (`mypy <src>` or `pyright`) is valuable but noisy on untyped/legacy code, so it is **not** part of the pre-commit gate. `workflow-init` offers to wire it up as a project choice; if enabled, run it in the agent-responsibility step, not the hook.

## Dependency manager detection

| Lockfile / marker in root | Manager        | Run a tool with                                |
| :------------------------ | :------------- | :--------------------------------------------- |
| `uv.lock`                 | **uv**         | `uv run <cmd>` · install: `uv sync`            |
| `poetry.lock`             | **Poetry**     | `poetry run <cmd>` · install: `poetry install` |
| `requirements*.txt` only  | **pip + venv** | activate venv, run `<cmd>` directly            |

Throughout this pack, `<run>` denotes the matching prefix (`uv run`, `poetry run`, or nothing in an activated venv).

## Mandatory dev dependencies

Every project initialized with this workflow ships with (in the `dev`/`test` group of `pyproject.toml`):

| Package                                                | Role                       |
| :----------------------------------------------------- | :------------------------- |
| `ruff`                                                 | Lint + format              |
| `bandit`                                               | Static security analysis   |
| `pytest`                                               | Test runner                |
| `pytest-cov`                                           | Coverage reporting         |
| Django: `pytest-django` · FastAPI: `httpx`             | Framework test integration |
| factories: `factory_boy` + `faker`                     | Test data                  |
| HTTP mocking: `respx` (httpx) / `responses` (requests) | Network stubbing           |

Pin in `pyproject.toml`; let the lockfile freeze exact versions. Run the manager's `outdated` check at init.

## Pre-commit gate (what the hook runs)

In a Python project (`pyproject.toml` / `setup.py` / `setup.cfg` present) the hook blocks `git commit` unless:

1. The branch is not `main`/`master`.
2. `ruff check --force-exclude <changed files>` is clean **and** `ruff format --check --force-exclude <changed files>` reports no reformatting.
3. `bandit -q <changed .py files>` reports no issues (when installed; a `[tool.bandit]` config in `pyproject.toml` is honored).

Checks are scoped to the Python files the commit touches (staged + unstaged vs `HEAD`) — pre-existing offenses elsewhere never block a commit. A commit touching no Python files skips the tool runs entirely; run the full-repo sweeps in CI or the Phase 4 review.

A repo with zero commits is exempt from the whole gate (greenfield bootstrap); `SKIP_COMMIT_GATE=1` in the launch environment disables it.

The hook deliberately does **not** run pytest — TDD Step 3 commits intentionally failing tests.

## Before an implementation commit (agent responsibility)

1. **N+1 / query audit:** assert query counts around the changed flow (`django_assert_num_queries` / the SQLAlchemy query-count fixture). Python has no ambient "raise on N+1" tool like Bullet, so this is **assertion-based** — see `running_tests.md`.
2. **Style cleanup:** `<run> ruff check --fix .` and `<run> ruff format .`, then the `ruff-fixer` agent for residual offenses. `UNRESOLVABLE` items need human review.
3. **Green suite:** `<run> pytest` passes.
