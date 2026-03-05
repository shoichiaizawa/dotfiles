---
paths:
  - ".claude/settings.json"
---

- **Hooks format**: use the array form — `"hooks": [{"type": "command", "command": "..."}]` — not the legacy bare `"command": "..."` form.
- **Hook scope**: project hooks run relative to the repo root; use paths like `bash .claude/hooks/script.sh`.
- **Adding a new hook**: add a new entry in the appropriate `PostToolUse`/`PreToolUse` array with a `matcher` (pipe-separated tool names) and a `hooks` array.
