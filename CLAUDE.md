# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal macOS dotfiles managed as a git repository. There is **no automated install script** — files are manually symlinked from `~/.dotfiles/` to their target locations in `$HOME` or `~/.config/`.

## Key Symlink Targets

| Repo path | Target |
|---|---|
| `bash/bash_profile` | `~/.bash_profile` |
| `bash/bashrc` | `~/.bashrc` |
| `bash/bash_prompt` | `~/.bash_prompt` |
| `git/gitconfig` | `~/.gitconfig` |
| `git/gitignore_global` | `~/.gitignore_global` |
| `vim/vimrc` | `~/.vimrc` |
| `tmux/tmux.conf` | `~/.tmux.conf` |
| `starship.toml` | `~/.config/starship.toml` |
| `inputrc` | `~/.inputrc` |
| `claude/settings.json` | `~/.claude/settings.json` |

## Architecture

### bash/
- `bash_profile` — login shell entry point; sources `bashrc`, shows welcome banner
- `bashrc` — monolithic interactive shell config organized into 14 numbered sections (see below)
- `bash_prompt` — prompt string definitions sourced by bashrc (overridden by starship if installed)
- `welcome.sh` — colored ASCII art + system info displayed at login

#### bashrc section map

| # | Section | Contents |
|---|---------|----------|
| 1 | PREAMBLE | `MYNAME`, `LESS`, `VISUAL`, `EDITOR`, `PYTHONSTARTUP` |
| 2 | PATH SETTINGS | `brew shellenv`, `BREW_PREFIX` cache, `LESSOPEN`, composer, diff-highlight; Java/SDKMAN subsection |
| 3 | HISTORY SETTINGS | `histappend`, `HISTSIZE`, `HISTFILESIZE`, `HISTTIMEFORMAT`, `HISTCONTROL`, `HISTIGNORE` |
| 4 | SHELL OPTIONS | `set -o noclobber`, all `shopt` commands |
| 5 | COLOR SETTINGS | `CLICOLOR`, `LSCOLORS`, `GREP_COLOR`, `GREP_OPTIONS` |
| 6 | PROMPT | `source ~/.bash/bash_prompt`, PS1 reference table |
| 7 | GENERAL COMPLETIONS | brew bash_completion, SSH, z.sh, git `g` alias, cask, Vagrant, killall, Composer, Terraform |
| 8 | ALIASES | Grouped subsections: safety, ls, tree, df/du, pagers, editors, cd/nav, mkdir, time, clipboard, history, ssh-keygen, grep, mute, macOS, networking, git, homebrew, python, docker, chrome, config-edit, apps, typos, utilities |
| 9 | FUNCTIONS | `cd()`, `mcd()`, `man()`, `extract()`, `path()`, `cdf()`, `trash()`, `ql()`, `ii()`, `rmh()`, `open-chrome-tabs()`, `toggleiTerm()`, `heroku-static-test()`, `vintage()`, fzf config |
| 10 | LANGUAGE RUNTIMES & PACKAGE MANAGERS | Subsections: rbenv, nvm / npm, pnpm, Bun |
| 11 | SHELL ENHANCEMENTS | Subsections: starship, thefuck, direnv, tealdeer |
| 12 | CLOUD & INFRASTRUCTURE | Subsections: Google Cloud SDK, Kubernetes |
| 13 | DEV TOOLS & EDITORS | Subsections: Visual Studio Code, bit, console-ninja, Ollama, Codex, deck, Google Antigravity |
| 14 | SYSTEM & MISC | Subsections: Alfred, .local/bin/env |
| — | PATH DEDUP | `awk` dedup to prevent PATH growth on re-source |

### git/
- `gitconfig` — includes `~/.gitconfig.local` (machine-specific overrides) and `~/work/.gitconfig` (work identity); uses `delta` for diffs
- `gitignore_global` — global ignores for Vim swap files, macOS artifacts

### vim/
- `vimrc` — uses `vim-plug` for plugin management (~47 plugins); `coc.nvim` for LSP; organized into fold sections (`{{{1`/`}}}1` with `{{{2` sub-folds)
- `autoload/plug.vim` — vim-plug bootstrap

#### vimrc section map

| Section | Sub-folds | Contents |
|---------|-----------|----------|
| Header & Section Map | — | file header, migration TODO, known issues |
| Plugin Manager: vim-plug | — | bootstrap, `plug#begin`/`plug#end`, plugin list |
| General Settings | Core Options, Tabs & Indentation, Folding, Appearance, Search, Line Wrap & Display, Splits & Windows, Backups & Undo | all `set` commands, highlights, `mapleader` |
| Filetype Autocmds | — | non-plugin ft detection: ejs, CSON, JavaScript, JSON, Markdown, Python, Vim, Line Return, QuickFix |
| Plugin Settings (×29) | — | one `{{{1` per plugin, alphabetical: Airline … vim-vue |
| General Mappings | Arrow Keys, Character Enhancements, Search, Brackets & Quotes, Escape, Line Movement, Window Navigation, Statement Separators, Tab & Buffer Navigation, Folding, Unhighlighting, Miscellaneous | non-plugin key bindings |
| General Functions | Incr(), Decr(), CohamaSmoothScroll(), Preserve(), CycleMetasyntacticVariables() | utility functions + their mappings |

### tmux/
- `tmux.conf` — prefix is `Ctrl+Q` (not `Ctrl+B`); pane/window index starts at 1
- `bin/battery`, `bin/wifi` — shell scripts for the tmux status line

### macOS system preferences
- `macos` — executable bash script; run manually with `bash macos` to apply macOS `defaults write` settings (many are commented out)

## Conventions

- Commit messages use Conventional Commits format: `feat(scope): message`, `fix(scope): message`
- Scope typically matches the config area being changed (e.g., `bashrc`, `vimrc`, `gitconfig`)
- The `bashrc` file is intentionally monolithic

### Editing bashrc

- **Adding a new alias or function**: place it in the appropriate subsection of §8 (ALIASES) or §9 (FUNCTIONS). Do not append to the end of the file.
- **Adding a new tool** (with its own PATH, aliases, and completions): add a new subsection in the appropriate §10–§14 category, or create a new §15+ category. Keep PATH + aliases + completions for that tool together.
- **Heading hierarchy in §10–§14**: category sections use 80-cpl `####` fences (same style as §1–§9); tool subsections use 60-cpl `# ---` boxes with no number. Do not mix the two styles.
- **`[SUGGESTION]` comments**: these are annotate-only markers for dead/broken code — do not remove them without also fixing or deleting the code they describe. Do not add new `[SUGGESTION]` comments for things that are working correctly.
- **Do not scatter tool-specific PATH entries** into §2 (PATH SETTINGS); §2 is for general/bootstrap PATH only. Tool-specific PATH belongs in the tool's own subsection within §10–§14.
- **Self-aliases** (`alias foo=foo` after `function foo`) are no-ops in bash — do not add new ones.
- **`$1`/`$2` in aliases** are not expanded; use a function instead if arguments are needed.

### Editing vimrc

- **Adding a new plugin**: add the `Plug` line in Plugin Manager, then create a new `Plugin Settings: <name> {{{1` section in alphabetical order among the existing plugin sections. Keep all settings + mappings + autocmds for that plugin together in its section.
- **Adding a non-plugin mapping or setting**: place it in the appropriate sub-fold (`{{{2`) of General Settings, General Mappings, or General Functions. Do not append to the end of the file.
- **`[SUGGESTION]` comments**: same convention as bashrc — annotate-only markers for commented-out alternatives. Do not remove without fixing or deleting the code they describe.
- **Plugin-specific `set` commands** (e.g., `set nobackup` in coc.nvim): keep them in the plugin's section, not in General Settings.
- **Each plugin section should be self-contained**: settings, mappings, autocmds, and functions for one plugin all belong in its `{{{1` section, so it maps cleanly to a future `lua/plugins/<name>.lua` file.
