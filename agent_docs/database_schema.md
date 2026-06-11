# Database Design and Migration Playbook

This playbook outlines the mandatory standards for modifying the database schema and structuring ActiveRecord relationships inside Rails projects.

> **Database Target:** This document targets **PostgreSQL**. Patterns such as `algorithm: :concurrently` and some locking semantics do not apply to MySQL or SQLite. Verify before running migrations on a non-PG database.

## DATA INTEGRITY & DATABASE-LEVEL CONSTRAINTS

Relying solely on Rails model validations is a critical anti-pattern. Race conditions can bypass application-level validations, leading to corrupt or orphan records. All core business constraints must be enforced at the database layer.

### Non-Null Columns

If a column should never be empty, enforce it explicitly in the database migration using null: false.

```
# Good
add_column :users, :email, :string, null: false

# Bad
add_column :users, :email, :string
```

### Unique Indexes

Any field that must be unique (e.g., account IDs, usernames, emails, transactional tokens) must possess a unique database index to prevent duplicate inserts during high-concurrency operations.

```
# Good
add_index :users, :email, unique: true
```

### Foreign Keys & Cascades

Never allow orphan records in your schema. Always write foreign key associations with strict referential safety:

```
# Good
create_table :orders do |t|
  t.references :user, null: false, foreign_key: true
  t.timestamps
end
```

## ENUM COLUMNS

Always back Rails enums with **string columns**, not integers. Integer enums silently corrupt data if the list is ever reordered.

```ruby
# Good — explicit, readable, safe to reorder
add_column :orders, :status, :string, null: false, default: 'pending'

# In the model:
enum :status, { pending: 'pending', confirmed: 'confirmed', shipped: 'shipped' }

# Bad — integer-backed enums break if entries are inserted out of order
add_column :orders, :status, :integer, default: 0
```

Always add a `null: false` constraint and a sensible `default:` value when defining an enum column.

## INDEXING STRATEGY (FAST QUERIES)

Database lookups degrade exponentially without correct index placement. Every query must be performant.

### Non-Negotiable Indexing Mandates:

**Foreign Keys:** Every foreign key column (e.g., user_id, product_id) must have an index. Use foreign_key: true or index: true inside references.

**Frequent Filter Fields:** Any column actively targeted inside where, find_by, order, or group queries must be indexed.

**Composite/Multi-Column Indexes:** If queries frequently search across multiple parameters simultaneously, construct a composite index (ensure column order matches query specificity, placing the highest-filtering field first).

```
# Example Composite Index
add_index :orders, [:user_id, :status]
```

## STRONG MIGRATIONS (ZERO-DOWNTIME RELEASES)

This workspace bundles strong_migrations. You are strictly forbidden from writing database operations that block production tables, drop active tables, or cause app timeouts under load.

### Safe Migration Patterns:

* **Adding Column with Default Values:** Never write ``add_column :users, :role, :string, default: 'member'``. This rewrites every row on big tables. Instead, use safe backfilling:

```
# 1. Add column without default
add_column :users, :role, :string

# 2. Add default for future records
change_column_default :users, :role, from: nil, to: 'member'

# 3. Backfill existing records in small batches (e.g., via a post-deployment task)
```

* **Removing Columns:** Never drop a database column directly.
```
    1. Mark the column ignored in the model file: self.ignored_columns = [:old_column_name].
    2. Deploy code.
    3. Once the live application is no longer reading or writing to the column, write a migration to safely drop it.
```

* **Adding Indexes Instantly (PostgreSQL):** Always execute index generation concurrently to prevent table locks:
```
class AddIndexToUsersEmail < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :users, :email, unique: true, algorithm: :concurrently
  end
end
```
## SELF-VALIDATION CHECKLIST

STOP after writing any migration or schema change. Check every item before presenting it. If an item fails, fix it first.

1. **Non-null:** Does every column that must never be empty have `null: false`?
2. **Uniqueness:** Does every must-be-unique field have a unique database index?
3. **FK integrity:** Does every reference use `null: false, foreign_key: true`?
4. **FK indexes:** Is every foreign key column indexed?
5. **Filter indexes:** Are columns used in `where`/`find_by`/`order`/`group` indexed — composite where queries combine them, highest-filtering column first?
6. **Enum safety:** Is every enum string-backed, with `null: false` and a sensible `default:`?
7. **Zero-downtime:** Indexes added with `algorithm: :concurrently` + `disable_ddl_transaction!`? No default value on `add_column` for large tables? No direct column drops?

### Anti-pattern scan
- [ ] Validation that exists only in the model with no matching DB constraint
- [ ] Integer-backed enum
- [ ] `add_column ... default:` on a table that may be large in production
- [ ] A `belongs_to` whose column has no index

### Judgment calls
When a schema decision has multiple defensible options (composite index column order, polymorphic association vs separate tables, soft-delete vs hard-delete), present the options with trade-offs instead of silently choosing.
