# dotfiles

Personal macOS dotfiles, actively maintained.

## About

Shell, editor, and tool configuration for macOS (with Linux portability in mind).
Files are manually symlinked from `~/.dotfiles/` — there is no automated install script.

## What's here

| Config | Status |
|--------|--------|
| Bash (`bash/bashrc`) | Stable; monolithic, 14-section layout |
| Vim (`vim/vimrc`) | Stable; vim-plug + coc.nvim, ~47 plugins |
| Git (`git/gitconfig`) | Stable; delta for diffs, local overrides |
| tmux (`tmux/tmux.conf`) | Stable; prefix Ctrl+Q, 1-indexed |
| Starship (`starship.toml`) | Stable |
| Claude Code (`claude/`) | Skills + global permissions |
| macOS defaults (`macos`) | Run manually: `bash macos` |

## Installation

No automated script. Symlink files manually, e.g.:

```sh
ln -s ~/.dotfiles/bash/bashrc ~/.bashrc
ln -s ~/.dotfiles/git/gitconfig ~/.gitconfig
# … etc.
```

See `CLAUDE.md` for the full symlink table.

## Claude Code integration

`.claude/` contains project-level hooks (shellcheck on edit) and skills.
`claude/` (symlinked to `~/.claude/`) contains global skills: `/commit` and `/refactor-plan`.

## Acknowledgements

Inspired by dotfiles from:
[@mathiasbynens](https://github.com/mathiasbynens/dotfiles),
[@paulirish](https://github.com/paulirish/dotfiles),
[@sjl](https://bitbucket.org/sjl/dotfiles/src),
[@paulmillr](https://github.com/paulmillr/dotfiles),
[@alrra](https://github.com/alrra/dotfiles),
[@b4b4r07](https://github.com/b4b4r07/dotfiles).

## License

MIT © Shoichi Aizawa
