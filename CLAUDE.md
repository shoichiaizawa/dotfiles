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
- `bashrc` — monolithic interactive shell config: PATH, history, prompt, aliases, functions, completions
- `bash_prompt` — prompt string definitions sourced by bashrc
- `welcome.sh` — colored ASCII art + system info displayed at login

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
- The `bashrc` file is intentionally monolithic (modularization is a known TODO)
