#!/usr/bin/env bash
# PreToolUse gate: intercepts `git commit` and enforces the checks that must
# never depend on the agent remembering them (see agent_docs/coding_workflow.md).
#
# Deliberately does NOT run the spec suite: TDD Step 3 commits intentionally
# failing tests. The green-suite requirement applies only to implementation
# commits and stays with the agent.
set -u

input=$(cat)

if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
elif command -v python3 >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)
else
  # Crude fallback: substring detection on the raw JSON still catches `git commit`.
  cmd=$input
fi

# Only gate git commit invocations (handles `git commit` and `git -C <path> commit`).
# The leading character class includes quotes so the raw-JSON fallback also matches.
printf '%s' "$cmd" | grep -qE "(^|[;&|[:space:]\"'])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+commit" || exit 0

# The gate applies to Ruby/Rails projects only. In a plain docs/config repo
# (no Gemfile) the hook is a no-op.
[ -f Gemfile ] || exit 0

# symbolic-ref (not rev-parse) so detection works on a repo with zero commits.
branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
  echo "Blocked: direct commits to '$branch' are forbidden. Create a feature branch first — see agent_docs/coding_workflow.md, Phase 1." >&2
  exit 2
fi

if ! bundle exec rubocop --parallel --force-exclusion >&2; then
  echo "Blocked: RuboCop offenses present. Run 'bundle exec rubocop -A', then invoke the rubocop-fixer agent for residual offenses." >&2
  exit 2
fi

if bundle show brakeman >/dev/null 2>&1; then
  if ! bundle exec brakeman --quiet --no-pager >&2; then
    echo "Blocked: Brakeman reported security warnings. Resolve them before committing." >&2
    exit 2
  fi
fi

exit 0
