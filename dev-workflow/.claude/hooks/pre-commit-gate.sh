#!/usr/bin/env bash
# Commit gate: blocks commits on main/master or with linter/security
# failures. Dispatches on the marker file (Gemfile -> Ruby,
# pyproject.toml/setup.py/setup.cfg -> Python); inert elsewhere. Full behavior
# and rationale: the dev-workflow README ("Hook requirement").
#
# Two invocation modes:
#  - Claude Code PreToolUse hook (default): reads the tool-call JSON on
#    stdin, matches `git commit`, then runs the checks.
#  - Plain git pre-commit hook (`--git-hook`): git itself guarantees the
#    commit context, so the stdin parsing and command matching are skipped
#    and the checks run directly. Installed by workflow-init on harnesses
#    without PreToolUse hooks (Codex, Gemini CLI, ...).
#
# Checks run only on the files the commit can include (staged + unstaged vs
# HEAD) — pre-existing offenses elsewhere in the repo never block a commit.
# Full-repo sweeps belong to CI and the Phase 4 review, not this gate.
#
# Does NOT run the test suite — TDD Step 3 commits intentionally failing tests.
set -u

# Escape hatch. Read from the hook's own env, so prefixing it to the gated
# command has no effect — only the user's launch environment can set it.
if [ "${SKIP_COMMIT_GATE:-}" = "1" ]; then
  exit 0
fi

if [ "${1:-}" != "--git-hook" ]; then
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

# Files this commit can include: staged + unstaged changes vs HEAD (covers
# plain `git commit`, `git commit -a`, and `git commit <paths>` — a superset
# is fine; deleted files carry nothing to lint). NUL-delimited for safety.
changed_files=()
while IFS= read -r -d '' f; do
  [ -f "$f" ] && changed_files+=("$f")
done < <(git diff HEAD --name-only -z --diff-filter=ACMRT)

if [ "$lang" = ruby ]; then
  ruby_files=()
  for f in ${changed_files[@]+"${changed_files[@]}"}; do
    case "$f" in
      *.rb|*.rake|*.gemspec|Gemfile|*/Gemfile|Rakefile|*/Rakefile|config.ru|*/config.ru) ruby_files+=("$f") ;;
    esac
  done

  if [ ${#ruby_files[@]} -eq 0 ]; then
    exit 0
  fi

  if ! bundle exec rubocop --version >/dev/null 2>&1; then
    echo "Blocked: RuboCop is not available via 'bundle exec' — it is the linter this gate requires. Add 'rubocop' (and 'rubocop-rails') to the Gemfile and run 'bundle install' (see agent_docs/ruby/toolchain.md)." >&2
    exit 2
  fi

  # --force-exclusion keeps .rubocop.yml excludes effective for explicit paths.
  if ! bundle exec rubocop --parallel --force-exclusion "${ruby_files[@]}" >&2; then
    echo "Blocked: RuboCop offenses in the files this commit touches. Run 'bundle exec rubocop -A' on them, then invoke the rubocop-fixer agent for residual offenses." >&2
    exit 2
  fi

  if bundle show brakeman >/dev/null 2>&1; then
    # Scoped scan so legacy warnings elsewhere don't block the commit; the
    # full-app scan runs in the Phase 4 review. --only-files takes a
    # comma-separated list.
    only_files=$(IFS=,; printf '%s' "${ruby_files[*]}")
    if ! bundle exec brakeman --quiet --no-pager --only-files "$only_files" >&2; then
      echo "Blocked: Brakeman reported security warnings in the files this commit touches. Resolve them before committing." >&2
      exit 2
    fi
  fi
else
  py_files=()
  bandit_files=()
  for f in ${changed_files[@]+"${changed_files[@]}"}; do
    case "$f" in
      *.py) py_files+=("$f"); bandit_files+=("$f") ;;
      *.pyi) py_files+=("$f") ;;
    esac
  done

  if [ ${#py_files[@]} -eq 0 ]; then
    exit 0
  fi

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

  # --force-exclude keeps configured excludes effective for explicit paths.
  if ! $run ruff check --force-exclude "${py_files[@]}" >&2; then
    echo "Blocked: Ruff lint offenses in the files this commit touches. Run 'ruff check --fix' on them, then invoke the ruff-fixer agent for residual offenses." >&2
    exit 2
  fi

  if ! $run ruff format --check --force-exclude "${py_files[@]}" >&2; then
    echo "Blocked: changed files are not formatted. Run 'ruff format' on them and re-stage the changes." >&2
    exit 2
  fi

  if [ ${#bandit_files[@]} -gt 0 ] && $run bandit --version >/dev/null 2>&1; then
    # Explicit file targets — no -r sweep, so venv excludes are unnecessary.
    if [ -f pyproject.toml ] && grep -q "^\[tool.bandit\]" pyproject.toml 2>/dev/null; then
      bandit_cfg="-c pyproject.toml"
    else
      bandit_cfg=""
    fi
    if ! $run bandit -q $bandit_cfg "${bandit_files[@]}" >&2; then
      echo "Blocked: Bandit reported security issues in the files this commit touches. Resolve them before committing." >&2
      exit 2
    fi
  fi
fi

exit 0
