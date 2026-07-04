# Python Conventions (Beyond Ruff)

Ruff (lint + format) already enforces layout and style mechanically — import ordering, quoting, line length, f-string usage, unused imports, comprehension style, `pyupgrade` modernizations, and PEP 8 layout. Do not re-derive those rules from memory: run `ruff check --fix .` and `ruff format .` and let Ruff decide.

This document lists only the conventions a linter cannot reliably check.

## NAMING & INTERFACES
* **Predicate Names:** Boolean-returning functions and attributes read as a yes/no question — prefix with `is_`/`has_`/`can_`/`should_`, never a getter phrasing.
    * **Correct:** `user.is_active`, `order.has_shipped`, `def can_refund(self) -> bool:`
    * **Incorrect:** `user.get_active_status()`, `def refund_check(self):`
* **Type hints on public surfaces:** Every public function/method signature carries parameter and return type hints. Internal one-liners may omit them, but anything imported elsewhere must be typed.
* **Snake_case everywhere except classes:** functions, variables, modules → `snake_case`; classes → `PascalCase`; constants → `SCREAMING_SNAKE_CASE`. (Ruff/`pep8-naming` catches most, but not semantic mismatches.)

## CONSTANTS & MAGIC VALUES
* **Magic Values:** Never hardcode numeric or string constants inside functions, views, or models. Define them as module-level `SCREAMING_SNAKE_CASE` constants, or an `enum.Enum` when they form a closed set.
    * **Correct:** `MAX_RETRY_LIMIT = 3` at module top; `class Status(enum.StrEnum): PENDING = "pending"`
* **Truthiness over counting:** Use direct truthiness or `any()`/`all()`, not length comparisons, to test for presence.
    * **Correct:** `if users:` / `if any(u.is_admin for u in users):`
    * **Incorrect:** `if len(users) > 0:` / `if len([u for u in users if u.is_admin]) > 0:`

## DATACLASSES & EQUALITY
* **Prefer `@dataclass` (or Pydantic models) for value objects** rather than bare classes with manual `__init__`. Get `__eq__`/`__repr__` for free and avoid hand-rolled boilerplate that drifts.
* **`frozen=True` for value objects** that should be immutable and hashable. Don't add a mutable default — use `field(default_factory=...)` for lists/dicts.

## MEMOIZATION & CACHING SAFETY
* **`functools.cached_property` for lazy attributes** instead of hand-rolled `if self._x is None` guards — but only when the value cannot legitimately be `None`/falsy in a way that should re-compute. A `cached_property` caches the first result forever, including `None`.
* **`@functools.lru_cache` only on pure functions** with hashable args and no side effects. Never on methods that depend on mutable instance state — it keeps `self` alive and caches across instances unexpectedly.

## COMMENTS & DOCUMENTATION
* **Docstrings for public modules, classes, and functions** that aren't self-evident — one line stating intent, expanded only when behavior is non-obvious. Skip docstrings that merely restate the signature.
* **Inline comments explain *why*, not *what*.** Use a single `#` for the rare comment that clarifies non-obvious logic; never narrate code the reader can see.

## ERROR HANDLING
* **Never bare `except:` or blanket `except Exception:`** to swallow errors. Catch the narrowest exception that can actually occur, and either handle it meaningfully or re-raise.
* **Raise specific exceptions**, not `Exception("...")`. Define a small domain exception hierarchy where the app has distinct failure modes.
