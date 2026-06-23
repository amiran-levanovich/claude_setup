# Python Database Design & Migration Playbook

Mandatory standards for modifying the schema and structuring relationships in a Python project. The ORM and migration tool depend on the framework:

| Framework | ORM | Migration tool |
| :--- | :--- | :--- |
| **Django** | Django ORM | built-in migrations (`makemigrations` / `migrate`) |
| **FastAPI** (typical) | SQLAlchemy | **Alembic** (`alembic revision` / `alembic upgrade`) |

> **Database Target:** this document targets **PostgreSQL**. Patterns such as concurrent index creation and some locking semantics do not apply to MySQL or SQLite. Verify before running migrations on a non-PG database.

> **No `strong_migrations` equivalent:** Python has no widely-adopted gem-style guard that raises on unsafe migrations. The zero-downtime rules below are therefore **manual discipline** enforced by the Self-Validation Checklist — not a runtime safety net. Treat them as hard rules.

## DATA INTEGRITY & DATABASE-LEVEL CONSTRAINTS

Relying solely on application/serializer validation is a critical anti-pattern — race conditions bypass it, producing corrupt or orphan rows. Enforce core business constraints at the database layer.

### Non-Null Columns
```python
# Django
email = models.EmailField(null=False)            # null=False is the default; be explicit for clarity

# SQLAlchemy
email: Mapped[str] = mapped_column(String, nullable=False)
```

### Unique Indexes
Any must-be-unique field (account IDs, usernames, emails, tokens) needs a unique **database** index, not just app validation.
```python
# Django
class Meta:
    constraints = [models.UniqueConstraint(fields=["email"], name="uq_user_email")]

# SQLAlchemy
email: Mapped[str] = mapped_column(String, unique=True, index=True)
```

### Foreign Keys & Cascades
Never allow orphan rows. Always declare the FK with explicit on-delete behavior.
```python
# Django
user = models.ForeignKey(User, on_delete=models.CASCADE)   # choose CASCADE/PROTECT/SET_NULL deliberately

# SQLAlchemy
user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
```

## ENUM COLUMNS
Back enums with **string values**, not integers — integer enums silently corrupt data if the list is reordered.
```python
# Django
class Status(models.TextChoices):
    PENDING = "pending", "Pending"
    SHIPPED = "shipped", "Shipped"

status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING, null=False)

# SQLAlchemy — store the string value, not the position
status: Mapped[str] = mapped_column(String(20), nullable=False, default="pending")
```
Always pair an enum column with `null=False` and a sensible default.

## INDEXING STRATEGY

Lookups degrade exponentially without correct index placement.

* **Foreign keys:** every FK column must be indexed. (Django indexes FK columns by default; SQLAlchemy does **not** — add `index=True`.)
* **Frequent filter fields:** any column used in a `filter()`/`WHERE`/`order_by`/`group_by` must be indexed.
* **Composite indexes:** when queries filter on multiple columns together, add a composite index with the highest-filtering column first.
```python
# Django
class Meta:
    indexes = [models.Index(fields=["user_id", "status"])]

# SQLAlchemy
__table_args__ = (Index("ix_orders_user_status", "user_id", "status"),)
```

## ZERO-DOWNTIME MIGRATIONS

You are forbidden from writing migrations that block production tables, drop active tables, or cause timeouts under load.

* **Adding a column with a default:** a volatile/all-rows default rewrites the whole table on large tables. Add the column nullable (or with a constant DB-level default), then backfill in batches in a separate step.
* **Removing a column:** never drop directly. (1) stop the app reading/writing it, (2) deploy, (3) drop in a later migration.
* **Adding an index concurrently (PostgreSQL):** never build an index in a transaction holding a table lock.
```python
# Django — non-atomic migration + concurrent index
from django.contrib.postgres.operations import AddIndexConcurrently

class Migration(migrations.Migration):
    atomic = False
    operations = [
        AddIndexConcurrently("order", models.Index(fields=["email"], name="ix_order_email")),
    ]
```
```python
# Alembic — disable the transaction, build concurrently
def upgrade():
    op.create_index("ix_order_email", "order", ["email"], unique=True, postgresql_concurrently=True)
# In env.py / migration: run with transaction_per_migration off, or use op.get_context().autocommit_block().
```

## SELF-VALIDATION CHECKLIST

STOP after writing any migration or schema change. Check every item before presenting it. If an item fails, fix it first.

1. **Non-null:** Does every column that must never be empty have `null=False` / `nullable=False`?
2. **Uniqueness:** Does every must-be-unique field have a unique **database** index/constraint?
3. **FK integrity:** Does every relationship declare an explicit on-delete behavior and `nullable=False` where required?
4. **FK indexes:** Is every foreign key column indexed? (SQLAlchemy needs `index=True` explicitly.)
5. **Filter indexes:** Are columns used in `filter`/`WHERE`/`order_by`/`group_by` indexed — composite where queries combine them, highest-filtering column first?
6. **Enum safety:** Is every enum string-backed, with `null=False` and a sensible default?
7. **Zero-downtime:** Concurrent index creation in a non-atomic migration? No volatile default on `add_column` for large tables? No direct column drops?

### Anti-pattern scan
- [ ] Validation that exists only in the app/serializer with no matching DB constraint
- [ ] Integer-backed enum / `IntegerChoices` for a reorderable set
- [ ] Adding a column with an all-rows default on a table that may be large
- [ ] A foreign key whose column has no index (especially SQLAlchemy)
- [ ] Concurrent index inside an atomic/transactional migration (will error or lock)

### Judgment calls
When a schema decision has multiple defensible options (composite index column order, JSON column vs join table, soft-delete vs hard-delete), present the options with trade-offs instead of silently choosing.
