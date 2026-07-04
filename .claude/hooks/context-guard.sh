#!/usr/bin/env bash
# Context guard — manages the approach to auto-compact, which degrades quality:
#   UserPromptSubmit       -> inject a warning once context passes CONTEXT_GUARD_PCT
#                             (default 85) of CONTEXT_GUARD_WINDOW (default 200000),
#                             telling the agent to run transfer-context now
#   PreCompact (auto)      -> warn the user compaction is imminent (stderr)
#   SessionStart (compact) -> re-anchor the agent after compaction (injected context)
# Best-effort: silently inert without python3.
set -u

input=$(cat)
command -v python3 >/dev/null 2>&1 || exit 0
export CG_INPUT="$input"
exec python3 - <<'PY'
import json, os, sys, tempfile
from collections import deque

try:
    data = json.loads(os.environ.get("CG_INPUT") or "{}")
except ValueError:
    sys.exit(0)
event = data.get("hook_event_name", "")

if event == "PreCompact":
    print("[context-guard] Auto-compact is about to run. Post-compact quality is "
          "unreliable — prefer continuing in a fresh session from a transfer-context "
          "handoff.", file=sys.stderr)
    sys.exit(0)

if event == "SessionStart":
    print("[context-guard] Context was just compacted; summarized instructions are "
          "lossy. Before continuing, re-read in order: (1) the quick-reference card "
          "(agent_docs/core/quickref.md or craft_docs/core/quickref.md — project copy "
          "first, else the plugin copy), (2) any in-flight doc in docs/features/ or "
          "craft/ including its Review log, (3) the full workflow doc if still "
          "unsure. Then state which task/round you are on. If deep in a feature, "
          "offer the user a transfer-context handoff to a fresh session instead of "
          "pushing on.")
    sys.exit(0)

# UserPromptSubmit: measure real context usage from the transcript's last usage record.
path = data.get("transcript_path") or ""
if not path or not os.path.exists(path):
    sys.exit(0)

last = None
try:
    with open(path, errors="ignore") as fh:
        for line in deque(fh, maxlen=400):
            try:
                usage = json.loads(line).get("message", {}).get("usage")
            except Exception:
                continue
            if usage and (usage.get("input_tokens") or usage.get("cache_read_input_tokens")):
                last = usage
except OSError:
    sys.exit(0)
if not last:
    sys.exit(0)

used = (last.get("input_tokens", 0)
        + last.get("cache_read_input_tokens", 0)
        + last.get("cache_creation_input_tokens", 0))
# Window is not recorded in the transcript; default 200k. On a 1M-context model
# set CONTEXT_GUARD_WINDOW=1000000 in the launch environment.
window = int(os.environ.get("CONTEXT_GUARD_WINDOW", "200000"))
threshold = int(os.environ.get("CONTEXT_GUARD_PCT", "85"))
pct = min(used * 100 // window, 100)
if pct < threshold:
    sys.exit(0)

# Warn once, then again only per +5 points, so the agent isn't nagged every prompt.
sid = data.get("session_id", "unknown")
marker = os.path.join(tempfile.gettempdir(), f"claude-context-guard-{sid}")
prev = -1
try:
    prev = int(open(marker).read().strip())
except Exception:
    pass
if prev >= threshold and pct < prev + 5:
    sys.exit(0)
with open(marker, "w") as fh:
    fh.write(str(pct))

print(f"[context-guard] This conversation is at ~{pct}% of the context window — "
      "auto-compact is close, and quality degrades sharply after it. Unless the "
      "current task is nearly done: (1) bring the in-flight doc (docs/features/… or "
      "craft/…, including its Review log) up to date, (2) run the transfer-context "
      "command to write a handoff file, (3) give the user the one-liner to continue "
      "in a fresh session.")
PY
