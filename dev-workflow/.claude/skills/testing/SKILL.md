---
name: testing
description: Use when writing or running tests in a Ruby/Rails (RSpec) or Python (pytest) project — system/integration tests, request/API specs, factories, mocking external services, or speeding up a slow suite — or when the user says 'write specs', 'test this', 'add tests', 'tests are slow', 'cover this with tests', or 'mock this API'.
---

First detect the project language by its marker file in the project root (one check — don't search subdirectories): `Gemfile` → `ruby`, `pyproject.toml`/`setup.py`/`setup.cfg` → `python`. Then read that language's testing runbook and follow it:

- ruby → `agent_docs/ruby/running_tests.md`
- python → `agent_docs/python/running_tests.md`

Locate the file as follows: use `agent_docs/<lang>/running_tests.md` in the project root if present (drop-in install); otherwise read `../../../agent_docs/<lang>/running_tests.md` relative to this skill's directory (plugin install). Those two locations are the only ones: if neither resolves, report the broken install and stop — never search the filesystem for `agent_docs`. If both or neither marker is present, ask the user which language pack applies.

It is the single source of truth for the testing hierarchy (integration/system over unit), factory strategy, mocking rules, query-count (N+1) assertions, and execution commands.
