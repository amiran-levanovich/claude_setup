---
name: greenfield-setup
description: Use when initializing a brand-new Ruby/Rails or Python (Django/FastAPI) project or major standalone subsystem from scratch, or when the user says 'new project', 'start from scratch', 'rails new', 'greenfield', or 'bootstrap the app'. Covers requirements gathering, architecture diagrams, data modeling, framework selection, mandatory tooling, and the sign-off gate before any feature code.
---

Determine the language first. A greenfield repo usually has no marker file yet, so detection may be inconclusive:

- If a marker already exists, use it: `Gemfile` → `ruby`, `pyproject.toml`/`setup.py`/`setup.cfg` → `python`.
- Otherwise, ask the user which language to scaffold (Ruby/Rails or Python) via the AskUserQuestion tool.

Then read that language's greenfield playbook and follow it:

- ruby → `agent_docs/ruby/building_the_project.md`
- python → `agent_docs/python/building_the_project.md`

Locate the file as follows: use `agent_docs/<lang>/building_the_project.md` in the project root if present (drop-in install); otherwise read `../../../agent_docs/<lang>/building_the_project.md` relative to this skill's directory (plugin install).

It is the single source of truth for the greenfield phase sequence (Phases 0–4) and the sign-off gate that must be cleared before feature coding begins. For Python, Phase 1 includes the framework choice (Django vs FastAPI), which determines the ORM, migration tool, and test client.
