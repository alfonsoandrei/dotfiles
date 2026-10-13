# dotfiles

Terminal configuration managed with [GNU Stow](https://www.gnu.org/software/stow/). `./install.sh` supports macOS and Omarchy.

## What's included

| Package | Symlinks to | Contents |
|---------|-------------|----------|
| `zsh` | `~/.zshrc` | Oh My Zsh, Powerlevel10k, aliases, functions |
| `git` | `~/.gitconfig` | delta pager, nvim-lite diff, codediff merge, GPG signing |
| `config` | `~/.config/git/ignore`, `~/.config/ghostty/config` | Global gitignore, Ghostty |
| `ssh` | `~/.ssh/config` | Shared SSH config and `gpg-connect-agent` tty update |
| `macos-ssh` | `~/.ssh/config.d/orbstack.conf` | macOS-only OrbStack include |
| `scripts` | `~/.scripts/`, `~/.local/bin/` | [2FA](scripts/README.md#2fa-yubikey-oath), [pass picker](scripts/README.md#pass-password-store), clipboard helpers, `pinentry-auto` |
| `nvim-lite` | `~/.config/nvim-lite/` | Neovim config (`NVIM_APPNAME=nvim-lite`) |
| `themes` | `~/.zsh2000-node/` | Zsh theme (submodule → [alfonsoandrei/zsh2000-node](https://github.com/alfonsoandrei/zsh2000-node)) |
| `opencode` | `~/.config/opencode/` | Opencode configuration |
| `tmux` | `~/.tmux.conf` | tmux config and TPM plugins |
| `gnupg` | `~/public-keys/` | Public keys used by `setup-pass.sh` |

`gpg-agent.conf` is generated, not stowed. `./install.sh`, `./setup-gpg-agent.sh`, and `./setup-yubikey.sh` render it from `install/gpg-agent.conf.in` into `GNUPGHOME` (default `~/.gnupg`) with an absolute `pinentry-auto` path.

Machine-specific files (`~/.zshrc.local`, `~/.gitconfig.local`) are sourced and never committed.

---

## New machine setup

### 1. Clone

```bash
git clone --recurse-submodules https://github.com/alfonsoandrei/dotfiles.git ~/dotfiles
```

`--recurse-submodules` pulls the zsh2000-node theme.

### 2. Bootstrap

```bash
cd ~/dotfiles && ./install.sh
```

### On macOS, this will:

- Install Homebrew packages from `Brewfile`
- Install Oh My Zsh, Powerlevel10k, and Zsh plugins
- Install NVM and Node LTS only when `~/.nvm` does not exist
- Install Neovim Node dependencies with `npm`
- Install tmux plugins and update submodules
- Create local override templates if missing
- Stow shared packages plus `macos-ssh`
- Render `gpg-agent.conf` and apply a macOS default

### On Omarchy, this will:

- Install required packages with `pacman` (`sudo` when needed)
- Install Oh My Zsh, Powerlevel10k, and Zsh plugins
- Install tmux plugins and update submodules
- Create local override templates if missing
- Stow shared packages
- Render `gpg-agent.conf`
- Append an idempotent handoff block to `~/.bashrc` that keeps bash as login shell and opens interactive shells in zsh

### 3. Fill local overrides

```bash
nvim ~/.zshrc.local
nvim ~/.gitconfig.local
```

See `zsh/.zshrc.local.example` and `git/.gitconfig.local.example`.

### 4. Configure gpg-agent

```bash
./setup-gpg-agent.sh
```

This enables GPG-based SSH auth and sets pinentry for the current machine.

### 5. Optional YubiKey setup

```bash
./setup-yubikey.sh
```

This restarts `gpg-agent`, imports your card key, and sets trust. If your card has no URL (`gpg --edit-card` → `url`), the script prints manual import steps.

### 6. Optional password-store setup

In `~/.zshrc.local`:

```bash
export PASSWORD_STORE_REPO=<my_git_repo>
export GPG_KEY_ID=<gpg key id>
```

Then:

```bash
./setup-pass.sh
```

### 7. Restart your terminal

---

## Manual Stow

Use this only when prerequisites are already installed. Stow links files only; it does not install packages, plugins, or generate `gpg-agent.conf`.

```bash
cd ~/dotfiles

# macOS
stow --simulate zsh git config ssh macos-ssh scripts nvim-lite themes opencode tmux gnupg
stow zsh git config ssh macos-ssh scripts nvim-lite themes opencode tmux gnupg

# Omarchy
stow --simulate zsh git config ssh scripts nvim-lite themes opencode tmux gnupg
stow zsh git config ssh scripts nvim-lite themes opencode tmux gnupg
```

On macOS, `macos-ssh` is required for `ssh orb`.

After manual Stow:

```bash
./setup-gpg-agent.sh
```

Run `./setup-yubikey.sh` only if you use a YubiKey.

---

## Local overrides

| File | Purpose |
|------|---------|
| `~/.zshrc.local` | Credentials, work functions, `PASSWORD_STORE_REPO`, `GPG_KEY_ID` |
| `~/.gitconfig.local` | Name, email, signing key |

```bash
cp ~/dotfiles/zsh/.zshrc.local.example ~/.zshrc.local
cp ~/dotfiles/git/.gitconfig.local.example ~/.gitconfig.local
```

If you do not use commit signing, set this in `~/.gitconfig.local`:

```ini
[commit]
    gpgSign = false
[merge]
    gpgSign = false
```

---

## Adding a package

1. Create the package directory to mirror `$HOME`.
2. Add the package name to `PACKAGES` in `install/common.sh` (or append in `install/macos.sh` for macOS-only packages).
3. Stow it from the repo root.

Example:

```bash
mkdir -p ~/dotfiles/wezterm
mv ~/.wezterm.lua ~/dotfiles/wezterm/.wezterm.lua
cd ~/dotfiles && stow wezterm
```

---

## Updating submodules

```bash
git submodule update --remote --merge
```

This updates the zsh2000-node theme.
