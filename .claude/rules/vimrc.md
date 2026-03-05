---
paths:
  - "vim/vimrc"
---

- **Adding a new plugin**: add the `Plug` line in Plugin Manager, then create a new `Plugin Settings: <name> {{{1` section in alphabetical order among the existing plugin sections. Keep all settings + mappings + autocmds for that plugin together in its section.
- **Adding a non-plugin mapping or setting**: place it in the appropriate sub-fold (`{{{2`) of General Settings, General Mappings, or General Functions. Do not append to the end of the file.
- **`[SUGGESTION]` comments**: same convention as bashrc — annotate-only markers for commented-out alternatives. Do not remove without fixing or deleting the code they describe.
- **Plugin-specific `set` commands** (e.g., `set nobackup` in coc.nvim): keep them in the plugin's section, not in General Settings.
- **Each plugin section should be self-contained**: settings, mappings, autocmds, and functions for one plugin all belong in its `{{{1` section, so it maps cleanly to a future `lua/plugins/<name>.lua` file.
