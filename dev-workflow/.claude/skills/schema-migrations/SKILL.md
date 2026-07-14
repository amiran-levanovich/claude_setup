---
name: schema-migrations
description: Use when creating or editing database migrations, designing schemas, adding indexes or constraints, or defining model associations and enums in a Ruby/Rails (ActiveRecord) or Python (Django ORM / SQLAlchemy + Alembic) project, or when the user says 'add a column', 'create a migration', 'new model', 'add an index', 'change the schema', or 'add an association'. Enforces PostgreSQL-safe, zero-downtime migration patterns.
---

First detect the project language by its marker file in the project root (one check — don't search subdirectories): `Gemfile` → `ruby`, `pyproject.toml`/`setup.py`/`setup.cfg` → `python`. Then read that language's database playbook and follow it:

- ruby → `agent_docs/ruby/database_schema.md`
- python → `agent_docs/python/database_schema.md`

Locate the file as follows: use `agent_docs/<lang>/database_schema.md` in the project root if present (drop-in install); otherwise read `../../../agent_docs/<lang>/database_schema.md` relative to this skill's directory (plugin install). Those two locations are the only ones: if neither resolves, report the broken install and stop — never search the filesystem for `agent_docs`. If both or neither marker is present, ask the user which language pack applies.

It is the single source of truth for database-level constraints, enum columns, indexing strategy, and zero-downtime migration patterns. For Python, the playbook branches on framework: Django migrations vs SQLAlchemy + Alembic.
