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
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `claude/settings.json` | `~/.claude/settings.json` |
| `claude/skills/` | `~/.claude/skills/` |

## Architecture

### bash/
- `bash_profile` — login shell entry point; sources `bashrc`, runs `fastfetch` (falls back to `welcome.sh`)
- `bashrc` — monolithic interactive shell config organized into 14 numbered sections (see below)
- `bash_prompt` — prompt string definitions sourced by bashrc (overridden by starship if installed)
- `welcome.sh` — colored ASCII art + system info displayed at login

#### bashrc section map

| # | Section | Contents |
|---|---------|----------|
| 1 | PREAMBLE | `MYNAME`, `LESS`, `VISUAL`, `EDITOR` |
| 2 | PATH SETTINGS | `brew shellenv`, `BREW_PREFIX` cache, diff-highlight |
| 3 | HISTORY SETTINGS | `histappend`, `HISTSIZE`, `HISTFILESIZE`, `HISTTIMEFORMAT`, `HISTCONTROL`, `HISTIGNORE` |
| 4 | SHELL OPTIONS | `set -o noclobber`, all `shopt` commands |
| 5 | COLOR SETTINGS | `CLICOLOR`, `LSCOLORS`, `GREP_COLOR`, `GREP_OPTIONS` |
| 6 | PROMPT | `source ~/.bash/bash_prompt`, PS1 reference table |
| 7 | GENERAL COMPLETIONS | brew bash_completion, SSH, zoxide, git `g` alias, Vagrant, killall, Terraform |
| 8 | ALIASES | Grouped subsections: safety, ls, tree, df/du, pagers, editors, cd/nav, mkdir, time, clipboard, history, ssh-keygen, grep, mute, macOS, networking, git, homebrew, python, docker, chrome, config-edit, apps, typos, utilities |
| 9 | FUNCTIONS | `cd()`, `mcd()`, `man()`, `extract()`, `path()`, `cdf()`, `trash()`, `ql()`, `ii()`, `rmh()`, `open-chrome-tabs()`, `heroku-static-test()`, `vintage()`, fzf config |
| 10 | LANGUAGE RUNTIMES & PACKAGE MANAGERS | Subsections: rbenv, nvm / npm, pnpm, Bun |
| 11 | SHELL ENHANCEMENTS | Subsections: starship, thefuck, direnv, tealdeer |
| 12 | CLOUD & INFRASTRUCTURE | Subsections: Google Cloud SDK, Kubernetes |
| 13 | DEV TOOLS & EDITORS | Subsections: Visual Studio Code, bit, console-ninja, Ollama, Codex, deck, Google Antigravity |
| 14 | SYSTEM & MISC | Subsections: Alfred, .local/bin/env |
| — | PATH DEDUP | `awk` dedup to prevent PATH growth on re-source |

### git/
- `gitconfig` — organised into `# ---` section groups (Identity, Core, Commands, Appearance, Aliases, Integrations); includes `~/.gitconfig.local` (machine-specific overrides) and `~/work/.gitconfig` (work identity); uses `delta` for diffs
- `gitignore_global` — global ignores for Vim swap files, macOS artifacts

### vim/
- `vimrc` — uses `vim-plug` for plugin management (~45 plugins); `coc.nvim` for LSP; organized into fold sections (`{{{1`/`}}}1` with `{{{2` sub-folds); true colour via `termguicolors` with colourscheme switching (`solarized8` default, `cobalt2` alt, `:Colors` picker via fzf.vim)
- `autoload/plug.vim` — vim-plug bootstrap

#### vimrc section map

| Section | Sub-folds | Contents |
|---------|-----------|----------|
| Header & Section Map | — | file header, migration TODO |
| Plugin Manager: vim-plug | — | bootstrap, `plug#begin`/`plug#end`, plugin list |
| General Settings | Core Options, Tabs & Indentation, Folding, Appearance, Search, Line Wrap & Display, Splits & Windows, Backups & Undo | all `set` commands, highlights, `mapleader`, `termguicolors`, colourscheme persistence (`~/.vim/.colorscheme`), `s:FixHighlights()` + `PersistColorscheme` augroup |
| Filetype Autocmds | — | non-plugin ft detection: ejs, JavaScript, JSON, Markdown, Python, Vim, Line Return, QuickFix, Markdown Heading Mappings |
| Plugin Settings (~22) | — | one `{{{1` per plugin, alphabetical: Airline … vim-visual-multi |
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
- `rules/` — path-scoped editing conventions (bashrc, vimrc, gitconfig, claude settings, skills); loaded on demand via `paths` frontmatter
- `skills/refactor-plan/SKILL.md` — `/refactor-plan` skill: 3-phase audit → propose → implement workflow for structural refactors

### iterm2/
- `com.googlecode.iterm2.plist` — periodic backup of the running iTerm2 config. Updated manually. If switching to a different terminal emulator (WezTerm, Ghostty, etc.), this directory would be replaced or repurposed. As a tmux user, terminal emulator choice primarily affects GPU rendering, font ligatures, and OS integration — tmux handles the rest.

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
- **Co-Authored-By trailer**: always include `Co-Authored-By: Claude (<model>, <effort>) <noreply@anthropic.com>` when Claude contributed to the change. Use your actual model family + version (e.g., Opus 4.6) and reasoning effort level (high/medium/low).
- **Never amend, skip hooks, or force-push** unless the user explicitly asks.
- **Pre-commit hook failures**: fix the issue, re-stage, and create a NEW commit — do not amend, since the failed commit never happened.

### Communication Style

- Terse numbered replies (e.g., `3`, `2`) mean selecting from a numbered list just presented — don't ask for clarification
- Prefer proposing a concrete solution over asking multiple rounds of clarifying questions — iterate from a proposal
- When asked to "analyze", "audit", or "map" a file, produce analysis only — do not suggest fixes to working code unless explicitly asked

### Dotfiles Principles

- All files in this repo are intentionally tracked — don't suggest `.gitignore` additions without asking
- Trust existing shell syntax — if unsure whether constructs like `alias -- -='cd -'` are valid, assume they work
- When asked to refactor a large file, default to deep structural reorganization (numbered sections, per-feature grouping), not cosmetic cleanup — ask upfront if scope is unclear

### File-Specific Editing Rules

File-specific editing conventions live in `.claude/rules/` and are loaded automatically when the matching file is being worked on. See: `bashrc.md`, `vimrc.md`, `gitconfig.md`, `claude-settings-global.md`, `claude-settings-project.md`, `claude-skills.md`.
