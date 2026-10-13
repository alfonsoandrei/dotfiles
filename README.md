# dotfiles

Personal terminal configuration managed with [GNU Stow](https://www.gnu.org/software/stow/). `./install.sh` bootstraps macOS. On Omarchy it stops with "not implemented yet" and does not change the machine.

## What's included

| Package | Symlinks to | Contents |
|---------|-------------|----------|
| `zsh` | `~/.zshrc` | Oh My Zsh, Powerlevel10k, aliases, functions |
| `git` | `~/.gitconfig` | delta pager, nvim-lite diff, codediff merge, GPG signing |
| `config` | `~/.config/git/ignore`, `~/.config/ghostty/config` | Global gitignore, Ghostty |
| `ssh` | `~/.ssh/config` | GPG agent match. Includes `~/.ssh/config.d/*.conf` |
| `macos-ssh` | `~/.ssh/config.d/orbstack.conf` | macOS only. OrbStack SSH include |
| `scripts` | `~/.scripts/`, `~/.local/bin/` | [2FA](scripts/README.md#2fa-yubikey-oath), [pass picker](scripts/README.md#pass-password-store), clipboard helpers, `pinentry-auto` |
| `nvim-lite` | `~/.config/nvim-lite/` | Neovim config (`NVIM_APPNAME=nvim-lite`) |
| `themes` | `~/.zsh2000-node/` | Zsh theme (submodule → [alfonsoandrei/zsh2000-node](https://github.com/alfonsoandrei/zsh2000-node)) |
| `opencode` | `~/.config/opencode/` | Opencode configuration |
| `tmux` | `~/.tmux.conf` | tmux config and TPM plugins |
| `gnupg` | `~/public-keys/` | Public keys used by `setup-pass.sh` |

`gpg-agent.conf` is not stowed. `./install.sh` and `./setup-yubikey.sh` render it from `install/gpg-agent.conf.in` into `GNUPGHOME` (default `~/.gnupg`) with an absolute `pinentry-auto` path. An existing regular config keeps its other lines.

Machine-specific config lives in `~/.zshrc.local` and `~/.gitconfig.local`. Those files are not tracked.

---

## New macOS machine

### 1. Clone the repo

```bash
git clone --recurse-submodules https://github.com/alfonsoandrei/dotfiles.git ~/dotfiles
```

`--recurse-submodules` pulls the zsh2000-node theme.

### 2. Run the bootstrap script

```bash
cd ~/dotfiles && ./install.sh
```

On macOS this will:

- Install Homebrew, if missing, and the packages in `Brewfile`
- Install Oh My Zsh, Powerlevel10k, `zsh-autosuggestions`, and `zsh-syntax-highlighting`
- Install NVM, the latest LTS Node, and the Neovim Node tools
- Install the tmux plugins and initialize git submodules
- Create `zsh/.zshrc.local` and `git/.gitconfig.local` from the examples when they are missing
- Create `~/.ssh/config.d` and Stow the shared packages plus `macos-ssh`
- Stop before linking anything if Stow finds a conflict
- Render `gpg-agent.conf`
- Set the macOS window-drag default

### 3. Fill in local overrides

```bash
nvim ~/.zshrc.local      # credentials, work env vars, AWS functions
nvim ~/.gitconfig.local  # your name, email, GPG signing key
```

See [`zsh/.zshrc.local.example`](zsh/.zshrc.local.example) and [`git/.gitconfig.local.example`](git/.gitconfig.local.example).

### 4. Set up YubiKey (if using one)

Insert your YubiKey and run:

```bash
./setup-yubikey.sh
```

This restarts `gpg-agent` with SSH support, imports your public key from the card, and sets trust. It needs `gnupg` and `pinentry-mac`.

The card needs a public key URL (`gpg --edit-card`, then `url`). Without it, the script prints the card status and you import the key yourself.

### 5. Set up password-store (if using one)

In `~/.zshrc.local`:

```bash
export PASSWORD_STORE_REPO=<my_git_repo>
export GPG_KEY_ID=<gpg key id>
```

Then:

```bash
./setup-pass.sh
```

### 6. Restart your terminal

---

## Manual Stow

Use this only when Homebrew, Oh My Zsh, the Zsh plugins, Powerlevel10k, tmux plugins, and `stow` are already installed. Stow links files. It does not install those tools or render `gpg-agent.conf`.

```bash
cd ~/dotfiles

stow --simulate zsh git config ssh macos-ssh scripts nvim-lite themes opencode tmux gnupg
stow zsh git config ssh macos-ssh scripts nvim-lite themes opencode tmux gnupg
./setup-yubikey.sh
```

`macos-ssh` is required on a Mac. Without it, `~/.ssh/config` includes an empty `config.d` glob and `ssh orb` does not get the OrbStack host.

If Stow reports a conflict, move the existing file aside and run it again:

```bash
mv ~/.zshrc ~/.zshrc.bak
mv ~/.gitconfig ~/.gitconfig.bak
```

---

## Local overrides

| File | Purpose |
|------|---------|
| `~/.zshrc.local` | Credentials, work functions, `PASSWORD_STORE_REPO`, `GPG_KEY_ID` |
| `~/.gitconfig.local` | Name, email, GPG signing key |

```bash
cp ~/dotfiles/zsh/.zshrc.local.example ~/.zshrc.local
cp ~/dotfiles/git/.gitconfig.local.example ~/.gitconfig.local
```

---

## Adding a package

1. Create the package directory so it mirrors `$HOME`:
   ```bash
   mkdir -p ~/dotfiles/<package>/<path/relative/to/home>
   ```
2. Add the package name to `PACKAGES` in `install/common.sh`. A macOS-only package is appended in `install/macos.sh` instead.
3. Stow it from the repo:
   ```bash
   cd ~/dotfiles && stow <package>
   ```

Example, adding `~/.wezterm.lua`:

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
