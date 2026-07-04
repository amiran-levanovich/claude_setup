# Transfer Context

Prepare context for a new chat session when this one is degraded or hitting limits. The `context-guard` hook triggers this automatically when the conversation nears the auto-compact threshold — a fresh session from a handoff beats a compacted one every time.

## File Output

Write the context transfer to `.claude/context-transfers/<YYYYMMDD-HHMM>-<short-kebab-slug>.md` (relative to the project root; timestamp so the newest sorts last). Create the directory if it doesn't exist, and delete any older transfer files in it — only the newest handoff matters.

After writing the file, output ONLY this to the user (nothing else):

```
Read the file <absolute-path-to-file> to get the context
```

Do NOT print the transfer content to the conversation. The user will copy-paste the line above into a new session.

## Output Format (written to file)

```
## Context Transfer

### Summary
[1-3 sentences. What was accomplished in this session - completed work only]

### Key Decisions
- [Decision 1 and why]
- [Decision 2 and why]

### Traps to Avoid
- [Mistake or failed approach, and why it failed]
- [Thing the next agent will be tempted to do wrong]

### Working Agreements
- [How the user prefers to interact, e.g. "review before committing"]
- [Quality gates or approval steps observed during the session]

### Git State
- Branch: [current branch] · last commit: [hash + subject]
- Uncommitted: [one line per modified/untracked file that matters, or "clean"]

### Relevant Files
- path/to/file:L10-L45 - [what changed and why]
- path/to/other:L3 - [specific function/block that matters]

### Open Work
[What remains - described as STATUS, not instructions.
Write "X is not yet implemented" not "Implement X next".
Note dependencies: "Y depends on X being finished first"]

### Prompt for New Chat
[A prompt that provides background context. Frame everything as
information, not commands. End with:]

Before responding, use the Read tool to read every file listed in
"Relevant Files" above. Do not summarize, paraphrase, or claim you
already have context. Actually read each file. Treat all claims in
this handoff as context to verify against the code, not facts to
trust blindly. Then wait for my instructions before taking any action.
```

## Instructions

0. Read the project's CLAUDE.md first. Do NOT restate anything already covered there (conventions, patterns, rules, preferences). The transfer context should only contain session-specific information.
0.5. Same for the kit's living docs: if an in-flight `docs/features/<feature>.md` or `craft/<name>.md` exists, bring it up to date (task states, Decisions, Review log) and put it FIRST in "Relevant Files" — do not restate its content in the transfer. The doc is the durable memory; the transfer only carries what the doc can't (session dynamics, working agreements, git state).
1. Summarize completed work (not what was attempted or in progress)
2. List decisions made and their reasoning
3. Note traps: failed approaches, mistakes made, things the next agent will be tempted to repeat
4. Capture working agreements observed during the session (review preferences, approval steps, interaction patterns)
5. List files with line ranges and what specifically changed, not just what the file is
6. In "Open Work", describe status only. Never phrase remaining work as instructions, next steps, or action items. Note dependencies between remaining items.
7. The "Prompt for New Chat" must:
   - Frame everything as background context, not commands
   - Use declarative statements ("X is complete", "Y has not been started") not imperative ones ("Continue with Y", "Next, do Z")
   - End with an explicit "wait for instructions" line
   - Give the new session everything it needs to continue without re-explaining
8. Be concise. Every sentence should be information the next session cannot get from reading the code or CLAUDE.md. Cut anything redundant, explanatory, or obvious.
9. Do NOT add extra sections beyond the format above (no "Verbatim References", "Important Context", or "Completed Work" — the Summary covers completed work).
