# Python Testing Strategy & Execution Runbook

This runbook defines the testing hierarchy, priorities, and execution constraints for Python projects. Adapt based on whether the app is a full-stack server (Django with templates) or an API-only service (Django REST / FastAPI).

## TESTING PRIORITIES

Isolated unit tests are a **low** priority. The highest priority is integration tests that verify real request/response behavior and end-to-end functional contracts.

**HIGHEST PRIORITY:** End-to-end / API integration tests (full request cycle, real routing, DB) — exercising the actual endpoint, not a mocked view.

**LOWEST PRIORITY:** Isolated unit tests of single functions/methods.

## API INTEGRATION TESTS (the primary tool)

Test the strict input/output contract of each endpoint through the real app, not a hand-called view function.

* **Django:** use `pytest-django` with the test client (`client.get(...)` / DRF `APIClient`). Mark DB-touching tests with `@pytest.mark.django_db`.
* **FastAPI:** use `httpx.AsyncClient` against the ASGI app (or `TestClient`) with an overridden DB dependency pointing at the test database.

### Coverage Matrix
For every endpoint, explicitly assert three layers:

* **Happy path** — valid params, `200`/`201`, exact payload shape.
* **Bad path** — invalid params, `422`/`400`, the error body shape (not just the status).
* **Edge cases & fault tolerance** — third-party downtime, `500`s, timeouts.

**Error schema verification:** don't just assert "didn't crash." Assert the exact status code *and* the error payload shape (error keys/structure).

## FULL-STACK APPS: BROWSER / E2E TESTS

For apps with a server-rendered UI, add a thin layer of end-to-end tests for critical user journeys (e.g. via Playwright). Keep them minimal:

* **Headless only** — never boot a visual browser in CI.
* **One happy path per flow** — push edge-case validation down to API/integration tests.
* **Reset state between tests** — transactional rollback (`pytest-django` does this per test) or truncation, not manual cleanup.

## THE TOTAL MOCKING MANDATE

**Never make real network requests in tests.** You are forbidden from hitting live third-party servers during a test run.

* **`httpx` clients (FastAPI):** stub with **`respx`**.
* **`requests` clients:** stub with **`responses`** (or `requests-mock`).
* Mock at the **network layer**, asserting the outbound request and returning a controlled response — don't monkeypatch your own wrapper and call it covered.

## QUERY-COUNT (N+1) ASSERTIONS

Python has no ambient "raise on N+1" tool like Ruby's Bullet — N+1 protection is **assertion-based** and lives in the tests:

* **Django:** wrap the exercised flow in `django_assert_num_queries(n)` (pytest-django fixture) or `self.assertNumQueries(n)`. A regression that adds queries fails the test.
* **SQLAlchemy:** add a fixture that counts emitted statements via an `event.listen(engine, "after_cursor_execute", ...)` counter and assert the expected count.

Add a query-count assertion to the integration test for any endpoint that loads collections with relationships — that is where N+1s appear.

## FACTORY STRATEGY

Use **`factory_boy`** (+ `faker`) — one factory per model, traits for variations, never duplicated factories.

```python
class UserFactory(factory.django.DjangoModelFactory):  # FastAPI/SQLAlchemy: factory.alchemy.SQLAlchemyModelFactory
    class Meta:
        model = User

    email = factory.Sequence(lambda n: f"user{n}@example.com")
    name = factory.Faker("name")

    class Params:
        admin = factory.Trait(role="admin")
```

Rules:
* Use `build()` (no DB hit) in pure logic tests; `create()` only where a persisted row is required.
* Use traits for variants instead of copy-pasting factories.
* Don't mix factories and static fixtures for the same model in one suite.

## EXECUTION CHEAT SHEET

Run via your built-in Bash tool, prefixed with the dependency manager's runner (`uv run` / `poetry run` / activated venv — see `toolchain.md`):

```bash
<run> pytest                                  # whole suite
<run> pytest tests/api/test_orders.py         # one file
<run> pytest tests/api/test_orders.py::test_cancel_happy_path   # one test
<run> pytest -k "cancel and not slow"         # by keyword
<run> pytest -x                               # fast-fail: stop on first failure
<run> pytest -n auto                          # parallel (needs pytest-xdist)
<run> pytest --cov                            # with coverage (needs pytest-cov)
```

When the suite exceeds ~10 minutes, enable parallelism with **`pytest-xdist`** (`-n auto`). Ensure DB-touching tests are isolated per worker (pytest-django creates a DB per worker automatically).

## SELF-VALIDATION CHECKLIST

STOP after writing or changing tests. Check every item before presenting them. If an item fails, fix it first.

1. **Right level:** Is each behavior tested at the highest-priority level that fits — an API integration test through the real app — rather than a low-priority unit test of a single function?
2. **Coverage matrix (APIs):** Does every endpoint assert all three layers — happy path, bad path (`422`/`400` + body shape), and fault tolerance (downtime/timeouts)?
3. **Error schema:** Do error-path assertions check the exact status code *and* the error payload shape — not merely "doesn't 500"?
4. **No real network:** Is every third-party call stubbed at the network layer (`respx`/`responses`)?
5. **Query counts:** Does every collection-loading endpoint have an N+1 guard (`django_assert_num_queries` / SQLAlchemy counter)?
6. **Factory discipline:** `build()` in logic tests, `create()` only where persistence is required, traits instead of duplicated factories?
7. **DB marker:** Is every test that touches the DB marked (`@pytest.mark.django_db`) or using the right session fixture?

### Anti-pattern scan
- [ ] Test that hits a live external service
- [ ] Multiple unrelated assertions in one test (unclear which broke)
- [ ] Near-identical tests copy-pasted with small changes — use `@pytest.mark.parametrize`
- [ ] `create()` where `build()` would do
- [ ] Calling a view/handler function directly instead of going through the real request cycle
- [ ] Collection endpoint with no query-count assertion

### Judgment calls
When test granularity or mocking depth is genuinely ambiguous (mock a collaborator vs let the call go through; one parametrized test vs several explicit ones), present the options instead of silently choosing.
