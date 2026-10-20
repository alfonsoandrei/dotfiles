# dotfiles

**Updated:** 2026-10-15

## OVERVIEW

GNU Stow dotfiles with platform bootstrap in `install.sh`:
- macOS: full setup
- Omarchy: package install + shared config + bash-to-zsh handoff

## STRUCTURE

```
dotfiles/
├── install.sh          # Detects platform and dispatches
├── install/            # Shared, macOS, and Omarchy installer steps
├── Brewfile            # Homebrew packages
├── setup-gpg-agent.sh  # Render gpg-agent.conf and restart gpg-agent
├── setup-yubikey.sh    # Render gpg-agent.conf, import card key
├── setup-pass.sh       # Clone/configure password store
├── zsh/                # Oh My Zsh, aliases, functions
├── git/                # delta, nvim-lite diff, codediff merge
├── config/             # Ghostty, global gitignore, mdfried
├── ssh/                # Shared SSH config
├── macos-ssh/          # OrbStack include (macOS only)
├── macos-mdfried/      # Link to mdfried config at its macOS path
├── scripts/            # 2fa, pass picker, clipboard, pinentry-auto
├── nvim-lite/          # Neovim config
├── themes/             # zsh2000-node submodule
├── opencode/           # Opencode configuration
└── gnupg/              # Public keys
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Install | `install.sh`, `install/` | `install/common.sh`, `install/macos.sh`, `install/omarchy.sh` |
| Shell config | `zsh/` | `.zshrc`, `aliases.zsh`, `functions.zsh` |
| Git config | `git/.gitconfig` | delta, codediff merge, GPG signing |
| SSH | `ssh/.ssh/config` | Includes `~/.ssh/config.d/*.conf` |
| OrbStack | `macos-ssh/` | Stowed only on macOS |
| Scripts | `scripts/README.md` | 2fa, pass picker, clipboard, pinentry |
| Password store | `zsh/pass.zsh`, `setup-pass.sh` | shell integration + bootstrap |
| GPG agent | `install/gpg-agent.conf.in` | Rendered to `GNUPGHOME`, default `~/.gnupg` |
| Neovim | `nvim-lite/.config/nvim-lite/` | `NVIM_APPNAME=nvim-lite` |
| Markdown viewer | `config/.config/mdfried/config.toml` | macOS reads it through `macos-mdfried/` |
| Zsh theme | `themes/.zsh2000-node/` | Submodule |

## COMMANDS

```bash
./install.sh
cd ~/dotfiles && stow <package>
git submodule update --remote --merge
./setup-gpg-agent.sh
./setup-yubikey.sh
./setup-pass.sh
```

## LOCAL OVERRIDES

`~/.zshrc.local` and `~/.gitconfig.local` are sourced and never committed.

## NOTES

- Shared Stow packages are in `PACKAGES` inside `install/common.sh`.
- macOS adds the `macos-ssh` and `macos-mdfried` packages in `install/macos.sh`.
- Omarchy keeps bash as login shell and execs zsh for non-login interactive shells.
- Neovim config is `nvim-lite` via `NVIM_APPNAME=nvim-lite`.
- Ghostty config is `config/.config/ghostty/config`.
