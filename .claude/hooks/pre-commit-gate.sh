#!/usr/bin/env bash
# PreToolUse gate on `git commit`: blocks commits on main/master or with
# linter/security failures. Dispatches on the marker file (Gemfile -> Ruby,
# pyproject.toml/setup.py/setup.cfg -> Python); inert elsewhere. Full behavior
# and rationale: docs/dev-workflow.md ("Hook requirement").
#
# Does NOT run the test suite — TDD Step 3 commits intentionally failing tests.
set -u

# Escape hatch. Read from the hook's own env, so prefixing it to the gated
# command has no effect — only the user's launch environment can set it.
if [ "${SKIP_COMMIT_GATE:-}" = "1" ]; then
  exit 0
fi

input=$(cat)

if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
elif command -v python3 >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)
else
  # Crude fallback: substring detection on the raw JSON still catches `git commit`.
  cmd=$input
fi

# Match `git commit` with any global flags in between, so -c/-C/--no-pager
# can't slip past. Quotes stay in the boundary class deliberately: dropping
# them would open a `sh -c "git commit"` bypass (fail-closed beats fail-open).
git_flag='[[:space:]]+(-[cC][[:space:]]+[^[:space:]]+|--?[^[:space:]]+)'
printf '%s' "$cmd" | grep -qE "(^|[;&|[:space:]\"'])git(${git_flag})*[[:space:]]+commit([[:space:]]|$|[\"'])" || exit 0

# `git -C <path>`: run every check against the repo the commit targets.
gitdir=$(printf '%s' "$cmd" | sed -nE "s/.*(^|[;&|[:space:]\"'])git(${git_flag})*[[:space:]]+-C[[:space:]]+([^[:space:]]+)([[:space:]].*)?$/\4/p")
if [ -n "$gitdir" ]; then
  if ! cd "$gitdir" 2>/dev/null; then
    echo "Blocked: cannot resolve 'git -C $gitdir' target directory from the hook. Run the commit from inside that directory instead." >&2
    exit 2
  fi
fi

if [ -f Gemfile ]; then
  lang=ruby
elif [ -f pyproject.toml ] || [ -f setup.py ] || [ -f setup.cfg ]; then
  lang=python
else
  exit 0
fi

# Zero-commit repo: greenfield bootstrap, nothing to regress yet.
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  exit 0
fi

branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
  echo "Blocked: direct commits to '$branch' are forbidden. Create a feature branch first — see agent_docs/core/coding_workflow.md, Phase 1." >&2
  exit 2
fi

if [ "$lang" = ruby ]; then
  if ! bundle exec rubocop --version >/dev/null 2>&1; then
    echo "Blocked: RuboCop is not available via 'bundle exec' — it is the linter this gate requires. Add 'rubocop' (and 'rubocop-rails') to the Gemfile and run 'bundle install' (see agent_docs/ruby/toolchain.md)." >&2
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
    if [ -f pyproject.toml ] && grep -q "^\[tool.bandit\]" pyproject.toml 2>/dev/null; then
      bandit_args="-q -c pyproject.toml -r ."
    else
      # Bandit's built-in excludes don't cover virtualenvs.
      bandit_args="-q -r . -x ./.venv,./venv,./node_modules"
    fi
    if ! $run bandit $bandit_args >&2; then
      echo "Blocked: Bandit reported security issues. Resolve them before committing." >&2
      exit 2
    fi
  fi
fi

exit 0
