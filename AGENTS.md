# dotfiles - macOS Terminal Configuration

**Generated:** 2026-04-15
**Commit:** 9705fb2
**Branch:** main

## OVERVIEW

macOS dotfiles managed with GNU Stow. Each package symlinks to home directory.

## STRUCTURE

```
dotfiles/
├── install.sh          # Bootstrap: brew, omz, nvm, stow
├── Brewfile            # Homebrew packages
├── setup-yubikey.sh    # GPG SSH agent config
├── setup-pass.sh       # password-store setup
├── zsh/                # Oh My Zsh + plugins + aliases
├── git/                # delta pager, nvim diff/merge
├── config/             # Ghostty, btop, gitignore
├── ssh/                # GPG SSH agent, OrbStack
├── scripts/            # 2fa (ykman), pass picker
├── nvim/               # Neovim (submodule)
├── themes/             # zsh2000-node (submodule)
├── opencode/           # Opencode skills/config
└── gnupg/              # GPG public keys
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Shell config | `zsh/` | `.zshrc`, `aliases.zsh`, `functions.zsh` |
| Git config | `git/.gitconfig` | delta, nvim merge, GPG signing |
| Custom scripts | `scripts/.scripts/` | 2fa, pass picker |
| Password store | `zsh/pass.zsh` | pass integration |
| Neovim config | `nvim/.config/nvim/` | Submodule repo |
| Zsh theme | `themes/.zsh2000-node/` | Submodule repo |

## COMMANDS

```bash
# Bootstrap new machine
./install.sh

# Add new package
stow <package>

# Update submodules
git submodule update --remote --merge

# YubiKey setup
./setup-yubikey.sh

# Password store setup
./setup-pass.sh
```

## KEY ALIASES & FUNCTIONS

See `zsh/AGENTS.md` and `scripts/AGENTS.md` for full listings.

## LOCAL OVERRIDES

Machine-specific config in `~/.zshrc.local` and `~/.gitconfig.local` - NEVER committed.

## NOTES

- Zsh theme: submodule at `themes/.zsh2000-node/`
- Neovim config: submodule at `nvim/.config/nvim/`
- SSH uses GPG agent: `gpg-connect-agent UPDATESTARTUPTTY`
- Ghostty config: `~/.config/ghostty/`
