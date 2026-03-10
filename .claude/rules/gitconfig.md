---
paths:
  - "git/gitconfig"
---

- **Never add `[safe] directory = *`** or similar blanket security bypasses. This disables Git's dubious-ownership check (CVE-2022-24765). If a specific directory needs to be trusted, add only that path: `directory = /path/to/repo`.
- **Machine-specific overrides** belong in `~/.gitconfig.local` (included by gitconfig), not in the tracked file.
- **Section layout**: the file is organised into `# --- Group Name ---` comment headers: Identity & includes, Core & general, Command behaviour, Pager & appearance, Aliases, Integrations. Keep new settings in the appropriate group.
- **Alias style**: use `# ---` / `# section` / `# ---` box comments to group related aliases (add, branch, checkout, etc.). Keep aliases alphabetical by group.
- **Git config is INI format** (not TOML) — both `#` and `;` are valid comment characters; values are not quoted unless they contain special characters.
