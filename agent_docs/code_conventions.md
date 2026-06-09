# Ruby & Rails Styling Rules

This document establishes the code style, layout, and structural constraints for all Ruby and Rails development in this workspace.
## STRINGS & LITERALS

- **Frozen Comments:** **Always** place `# frozen_string_literal: true` at the very top of every `.rb` file. This prevents string allocations and saves memory. Enforced automatically by RuboCop (`Style/FrozenStringLiteralComment`) — CI will fail without it.
- **Single Quotes by Default:** Use single quotes ' for literal strings.
- **Double Quotes for Interpolation:** Use double quotes " only when you need string interpolation ("#{user.name}") or escaped control characters like \n.
- **String Arrays:** Define arrays of strings using the %w[...] shorthand. Do not write ['a', 'b', 'c'].
- **Symbol Arrays:** Define arrays of symbols using the %i[...] shorthand. Do not write [:a, :b, :c].  
## BOOLEANS & FLOW CONTROL
* **Predicate Queries:** Always write predicate methods for booleans rather than getter-style status checkers.
	* **Correct:** `user.active?`
	* **Incorrect:** `user.get_active_status`
+ **Guard Clauses:** Prefer early returns (guard clauses) to reduce deep indentation and nested if statements.
	+ Correct:
		  
          return unless user.active?
		   
          user.send_notification
	+ Incorrect:

		  if user.active?
		    user.send_notification
		  end
* **Avoid `unless ... else`:** Never pair unless with an else clause. Rephrase the logic using if instead.
* **Safe Navigation:** Use the safe navigation operator &. rather than verbose safe-checking or .try.
	* **Correct:** `user&.profile&.avatar_url`
	* **Incorrect:** `user && user.profile && user.profile.avatar_url`
## BLOCKS & CONTROL FLOW
* **One-Liners:** Use curly braces `{ ... }` for single-line blocks.
* **Multi-Liners:** Use `do ... end` for blocks spanning multiple lines.
* **Avoid Redundant Returns:** Never write explicit return statements on the last or only line of a method. Ruby implicitly returns the last evaluated statement.
* **Clean Returns:** Avoid returning nil explicitly. Use a bare return statement.
	* **Correct:** ``return unless record_found?``
	* **Incorrect:** ``return nil unless record_found?``
## COMMENTS & DOCUMENTATION
* **Method Summaries:** Write comments to explain complex logic or non-obvious code. Set the comment directly above the target method signature.
* **Single-Line Comments:** Use a single `#` for inline or standard single-line annotations.
## CONSTANTS & DATA MANIPULATION
* **Magic Values:** Never hardcode numeric or string constants within controllers, models, or jobs. Define them as screaming-snake-case constants at the top of the file.
	* **Correct:** `MAX_RETRY_LIMIT = 3`
* **Semantic Enumerables:** Use specialized enumerable methods instead of converting to arrays or counting elements to check truthiness.
	* **Correct:** `users.any? or users.none?`
	* **Incorrect:** ``users.count > 0 or users.select { ... }.empty?``
* **Idempotent Memoization:** Use the ``||=`` operator for lazy initialization, but make sure it is safe if the value can legitimately resolve to false or nil.
	* **Correct:** ``@current_user ||= User.find_by(id: session[:user_id])``