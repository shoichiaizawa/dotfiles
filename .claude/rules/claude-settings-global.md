---
paths:
  - "claude/settings.json"
---

- **Syntax**: use modern `Bash(cmd *)` format, not legacy `Bash(cmd:*)`.
- **Allow list**: only add read-only, non-destructive commands. Commands that modify state (git write ops, file edits, installs) should require per-use approval.
- **Deny list**: reserve for catastrophic/irreversible operations (e.g., `sudo`, `rm -rf /`, force push). Deny rules are hard blocks — they cannot be overridden by user approval.
- **Bare vs wildcard**: use `Bash(cmd)` for no-arg commands, `Bash(cmd *)` for commands with args. Note `Bash(cmd*)` (no space) also matches commands starting with `cmd` (e.g., `Bash(ps*)` matches `ps` and `pstree`).
