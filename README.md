# claude_setup → moved

This repo used to host a three-plugin Claude Code marketplace. The plugins now live in **standalone self-hosting repos** — full git history and version tags moved with them. This repo is just the pointer.

| Was | Now | For | Install |
| :-- | :-- | :-- | :------ |
| `dev-workflow` | [**redgreen**](https://github.com/amiran-levanovich/redgreen) | Code — Ruby on Rails & Python (TDD spine, pre-commit gate, fixer agents) | `/plugin marketplace add amiran-levanovich/redgreen`<br>`/plugin install redgreen@redgreen` |
| `craft-workflow` | [**atelier**](https://github.com/amiran-levanovich/atelier) | Non-code — design, content, research (agent-run gates, review loop) | `/plugin marketplace add amiran-levanovich/atelier`<br>`/plugin install atelier@atelier` |
| `job-workflow` | [**dossier**](https://github.com/amiran-levanovich/dossier) | Job search — verified knowledge base, tailored ATS-safe applications | `/plugin marketplace add amiran-levanovich/dossier`<br>`/plugin install dossier@dossier` |

All three share one method — *understand → plan → define "good" up front → produce → review-loop until a clean pass* — each repo's README tells the rest.

## If you installed from here

```
/plugin uninstall dev-workflow@claude-setup
/plugin uninstall craft-workflow@claude-setup
/plugin uninstall job-workflow@claude-setup
/plugin marketplace remove claude-setup
```

Then install from the new repos (table above). The old `<plugin>-v<version>` tags remain here for reference; nothing in this repo is maintained.
