# dotfiles

**Updated:** 2026-10-13

## OVERVIEW

GNU Stow dotfiles. `./install.sh` bootstraps macOS. On Omarchy it exits before changing the machine.

## STRUCTURE

```
dotfiles/
├── install.sh          # Detects the platform and dispatches
├── install/            # Shared, macOS, and Omarchy steps; gpg-agent template
├── Brewfile            # Homebrew packages
├── setup-yubikey.sh    # Render gpg-agent.conf, import the card key
├── setup-pass.sh       # Clone and trust the password store
├── zsh/                # Oh My Zsh, aliases, functions
├── git/                # delta, nvim-lite diff, codediff merge
├── config/             # Ghostty, global gitignore
├── ssh/                # Shared SSH config and GPG agent match
├── macos-ssh/          # macOS-only OrbStack include
├── scripts/            # 2fa, pass picker, clipboard, pinentry-auto
├── nvim-lite/          # Neovim config
├── themes/             # zsh2000-node submodule
├── opencode/           # Opencode configuration
├── tmux/               # tmux config
└── gnupg/              # Public keys
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Install | `install.sh`, `install/` | macOS installs. Omarchy is unimplemented |
| Shell config | `zsh/` | `.zshrc`, `aliases.zsh`, `functions.zsh` |
| Git config | `git/.gitconfig` | delta, codediff merge, GPG signing |
| SSH | `ssh/.ssh/config` | Includes `~/.ssh/config.d/*.conf` |
| OrbStack | `macos-ssh/` | Stowed only on macOS |
| Scripts | `scripts/README.md` | 2fa, pass picker, clipboard, pinentry |
| Password store | `zsh/pass.zsh`, `setup-pass.sh` | `pass.zsh` is shell integration |
| GPG agent | `install/gpg-agent.conf.in` | Rendered to `GNUPGHOME`, default `~/.gnupg` |
| Neovim | `nvim-lite/.config/nvim-lite/` | `NVIM_APPNAME=nvim-lite` |
| Zsh theme | `themes/.zsh2000-node/` | Submodule |

## COMMANDS

```bash
./install.sh
cd ~/dotfiles && stow <package>
git submodule update --remote --merge
./setup-yubikey.sh
./setup-pass.sh
```

## LOCAL OVERRIDES

`~/.zshrc.local` and `~/.gitconfig.local` are sourced and never committed.

## NOTES

- Shared Stow packages are `PACKAGES` in `install/common.sh`. macOS appends `macos-ssh`.
- Neovim config is `nvim-lite` via `NVIM_APPNAME=nvim-lite`.
- SSH runs `gpg-connect-agent UPDATESTARTUPTTY` for every host.
- Ghostty config is `config/.config/ghostty/config`.
