---
paths:
  - "git/gitconfig"
---

- **Never add `[safe] directory = *`** or similar blanket security bypasses. This disables Git's dubious-ownership check (CVE-2022-24765). If a specific directory needs to be trusted, add only that path: `directory = /path/to/repo`.
- **Machine-specific overrides** belong in `~/.gitconfig.local` (included by gitconfig), not in the tracked file.
