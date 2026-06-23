# Ruby & Rails Conventions (Beyond RuboCop)

RuboCop (with `rubocop-rails`) already enforces layout and style mechanically — quoting, `%w[]`/`%i[]` literals, `# frozen_string_literal: true`, block delimiters, guard clauses, `unless`/`else`, safe navigation, redundant returns. Do not re-derive those rules from memory: run `bundle exec rubocop -A` and let the cops decide.

This document lists only the conventions a linter cannot reliably check.

## NAMING & INTERFACES
* **Predicate Queries:** Always write predicate methods for booleans rather than getter-style status checkers.
	* **Correct:** `user.active?`
	* **Incorrect:** `user.get_active_status`

## CONSTANTS & MAGIC VALUES
* **Magic Values:** Never hardcode numeric or string constants within controllers, models, or jobs. Define them as screaming-snake-case constants at the top of the file.
	* **Correct:** `MAX_RETRY_LIMIT = 3`
* **Semantic Enumerables:** Use specialized enumerable methods instead of converting to arrays or counting elements to check truthiness.
	* **Correct:** `users.any?` or `users.none?`
	* **Incorrect:** `users.count > 0` or `users.select { ... }.empty?`

## COMMENTS & DOCUMENTATION
* **Method Summaries:** Write comments only to explain complex logic or non-obvious code. Set the comment directly above the target method signature.
* **Single-Line Comments:** Use a single `#` for inline or standard single-line annotations.

## MEMOIZATION SAFETY
* **Idempotent Memoization:** Use the `||=` operator for lazy initialization, but only when the memoized value cannot legitimately resolve to `false` or `nil` — otherwise the computation silently re-runs on every call. Use `defined?(@var) ? @var : @var = compute` for nullable results.
	* **Correct:** `@current_user ||= User.find_by(id: session[:user_id])` — acceptable only if a missing user re-querying is intended.
