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
| `claude/skills/` | `~/.claude/skills/` |

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

### claude/
- `settings.json` — global Claude Code permissions (symlinked to `~/.claude/settings.json`); contains `allow` (read-only/safe commands auto-approved) and `deny` (catastrophic operations hard-blocked even if user approves)
- `skills/commit/SKILL.md` — `/commit` skill: staged-change review → atomicity check → Conventional Commit message → commit workflow

### .claude/
Project-level Claude Code configuration — not symlinked; picked up automatically from the repo root.
- `settings.json` — project hooks config; uses `PostToolUse` to run `shellcheck-after-edit.sh` after Edit/Write
- `hooks/shellcheck-after-edit.sh` — runs `bash -n` (syntax check) and `shellcheck --severity=warning` on modified shell files (`bash/*`, `macos`, `tmux/bin/*`, `welcome.sh`); informational only, non-blocking
- `skills/refactor-plan/SKILL.md` — `/refactor-plan` skill: 3-phase audit → propose → implement workflow for structural refactors

### macOS system preferences
- `macos` — executable bash script; run manually with `bash macos` to apply macOS `defaults write` settings (many are commented out)

## Conventions

- Commit messages use Conventional Commits format: `feat(scope): message`, `fix(scope): message`
- Scope typically matches the config area being changed (e.g., `bashrc`, `vimrc`, `gitconfig`)
- The `bashrc` file is intentionally monolithic
- Do not suggest fixing working configurations unless explicitly asked

### Git Workflow

- **Atomic commits**: each commit should contain one logical change. Do not bundle unrelated changes.
- **Rewriting history**: use `git rebase -i` only for commits that are not yet pushed. For rewording or reordering non-HEAD commits, prefer interactive rebase over repeated amend.
- **Co-Authored-By trailer**: always include `Co-Authored-By: Claude <noreply@anthropic.com>` when Claude contributed to the change.
- **Never amend, skip hooks, or force-push** unless the user explicitly asks.
- **Pre-commit hook failures**: fix the issue, re-stage, and create a NEW commit — do not amend, since the failed commit never happened.

### Communication Style

- Terse numbered replies (e.g., `3`, `2`) mean selecting from a numbered list just presented — don't ask for clarification
- Prefer proposing a concrete solution over asking multiple rounds of clarifying questions — iterate from a proposal

### Dotfiles Principles

- All files in this repo are intentionally tracked — don't suggest `.gitignore` additions without asking
- Trust existing shell syntax — if unsure whether constructs like `alias -- -='cd -'` are valid, assume they work
- When asked to refactor a large file, default to deep structural reorganization (numbered sections, per-feature grouping), not cosmetic cleanup — ask upfront if scope is unclear

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

### Editing claude/settings.json (global Claude Code permissions)

- **Syntax**: use modern `Bash(cmd *)` format, not legacy `Bash(cmd:*)`.
- **Allow list**: only add read-only, non-destructive commands. Commands that modify state (git write ops, file edits, installs) should require per-use approval.
- **Deny list**: reserve for catastrophic/irreversible operations (e.g., `sudo`, `rm -rf /`, force push). Deny rules are hard blocks — they cannot be overridden by user approval.
- **Bare vs wildcard**: use `Bash(cmd)` for no-arg commands, `Bash(cmd *)` for commands with args. Note `Bash(cmd*)` (no space) also matches commands starting with `cmd` (e.g., `Bash(ps*)` matches `ps` and `pstree`).

### Editing .claude/settings.json (project hooks)

- **Hooks format**: use the array form — `"hooks": [{"type": "command", "command": "..."}]` — not the legacy bare `"command": "..."` form.
- **Hook scope**: project hooks run relative to the repo root; use paths like `bash .claude/hooks/script.sh`.
- **Adding a new hook**: add a new entry in the appropriate `PostToolUse`/`PreToolUse` array with a `matcher` (pipe-separated tool names) and a `hooks` array.

### Editing claude/skills/

- **Directory structure**: each skill lives in `claude/skills/<name>/SKILL.md`. The directory name becomes the slash-command (e.g., `claude/skills/commit/` → `/commit`).
- **No YAML frontmatter**: skills in this repo use a plain `# /<name>` heading, not YAML metadata blocks.
- **Global vs project-level**: skills in `claude/skills/` (symlinked to `~/.claude/skills/`) are available in all projects. A project can override a global skill by creating `.claude/skills/<name>/SKILL.md` at the project root.
- **Keep skills project-agnostic**: global skills should not reference repo-specific paths, tools, or conventions. Repo-specific instructions belong in CLAUDE.md or in a project-level skill override.
