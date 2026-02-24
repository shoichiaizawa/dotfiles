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
- `bashrc` — monolithic interactive shell config organized into 29 numbered sections (see below)
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
| 10 | rbenv | |
| 11 | nvm / npm | `nvm-upgrade-init`, `nvm-install`, npm aliases |
| 12 | pnpm | |
| 13 | Alfred | `HOMEBREW_CASK_OPTS` (commented out) |
| 14 | thefuck | |
| 15 | Google Cloud SDK | `gactivate`, `gssh`, `bqschema`, `bqtables` |
| 16 | direnv | |
| 17 | goenv | `goenv-git-upgrade` |
| 18 | starship | Overrides PS1 from `bash_prompt` |
| 19 | Kubernetes | kubectl, minikube, skaffold, kustomize |
| 20 | bit | |
| 21 | tealdeer | |
| 22 | Bun | |
| 23 | Visual Studio Code | `setup_vscode_completion` |
| 24 | console-ninja | |
| 25 | Ollama | `_complete_ollama` |
| 26 | .local/bin/env | |
| 27 | deck | `deckls` |
| 28 | Codex | |
| 29 | Google Antigravity | |

### git/
- `gitconfig` — includes `~/.gitconfig.local` (machine-specific overrides) and `~/work/.gitconfig` (work identity); uses `delta` for diffs
- `gitignore_global` — global ignores for Vim swap files, macOS artifacts

### vim/
- `vimrc` — uses `vim-plug` for plugin management (~100+ plugins); `coc.nvim` for LSP
- `autoload/plug.vim` — vim-plug bootstrap

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
- **Adding a new tool** (with its own PATH, aliases, and completions): add a new numbered fence section at the bottom (§30+), keeping PATH + aliases + completions for that tool together.
- **`[SUGGESTION]` comments**: these are annotate-only markers for dead/broken code — do not remove them without also fixing or deleting the code they describe. Do not add new `[SUGGESTION]` comments for things that are working correctly.
- **Do not scatter tool-specific PATH entries** into §2 (PATH SETTINGS); §2 is for general/bootstrap PATH only. Tool-specific PATH belongs in the tool's own fence section.
- **Self-aliases** (`alias foo=foo` after `function foo`) are no-ops in bash — do not add new ones.
- **`$1`/`$2` in aliases** are not expanded; use a function instead if arguments are needed.
