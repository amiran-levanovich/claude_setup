#!/usr/bin/env bash
# PreToolUse gate: intercepts `git commit` and enforces the checks that must
# never depend on the agent remembering them (see agent_docs/core/coding_workflow.md).
#
# Polyglot: dispatches on the project's marker file —
#   Gemfile                          -> Ruby/Rails  (RuboCop + Brakeman)
#   pyproject.toml / setup.py        -> Python      (Ruff lint+format + Bandit)
# Inert in any other repo.
#
# Deliberately does NOT run the test suite: TDD Step 3 commits intentionally
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

# Determine the project language by marker file. In a plain docs/config repo
# (no recognized marker) the hook is a no-op.
if [ -f Gemfile ]; then
  lang=ruby
elif [ -f pyproject.toml ] || [ -f setup.py ] || [ -f setup.cfg ]; then
  lang=python
else
  exit 0
fi

# Branch guard is language-agnostic. symbolic-ref (not rev-parse) so detection
# works on a repo with zero commits.
branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
  echo "Blocked: direct commits to '$branch' are forbidden. Create a feature branch first — see agent_docs/core/coding_workflow.md, Phase 1." >&2
  exit 2
fi

if [ "$lang" = ruby ]; then
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
else
  # Python: pick the dependency-manager runner by lockfile.
  if [ -f uv.lock ]; then
    run="uv run"
  elif [ -f poetry.lock ]; then
    run="poetry run"
  else
    run=""   # assume an activated venv / tools on PATH
  fi

  # $run is intentionally unquoted so "uv run" splits into two words.
  if ! $run ruff --version >/dev/null 2>&1; then
    echo "Blocked: ruff not found — it is the linter this gate requires. Install it (see agent_docs/python/toolchain.md)." >&2
    exit 2
  fi

  if ! $run ruff check . >&2; then
    echo "Blocked: Ruff lint offenses present. Run 'ruff check --fix .', then invoke the ruff-fixer agent for residual offenses." >&2
    exit 2
  fi

  if ! $run ruff format --check . >&2; then
    echo "Blocked: code is not formatted. Run 'ruff format .' and re-stage the changes." >&2
    exit 2
  fi

  if $run bandit --version >/dev/null 2>&1; then
    bandit_args="-q -r ."
    if [ -f pyproject.toml ] && grep -q "^\[tool.bandit\]" pyproject.toml 2>/dev/null; then
      bandit_args="-q -c pyproject.toml -r ."
    fi
    if ! $run bandit $bandit_args >&2; then
      echo "Blocked: Bandit reported security issues. Resolve them before committing." >&2
      exit 2
    fi
  fi
fi

exit 0
