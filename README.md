# dotfiles

Personal macOS terminal configuration managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's included

| Package | Symlinks to | Contents |
|---------|------------|----------|
| `zsh` | `~/.zshrc` | Oh My Zsh, FZF, NVM, GPG, general aliases |
| `git` | `~/.gitconfig` | delta pager, nvim diff/merge, GPG signing |
| `config` | `~/.config/git/ignore`, `~/.config/btop/btop.conf` | Global gitignore, btop settings |
| `ssh` | `~/.ssh/config` | GPG SSH agent, OrbStack integration |
| `scripts` | `~/.scripts/log-pretty.mjs` | JSON log formatter |
| `nvim` | `~/.config/nvim/` | Neovim config (submodule → [alfonsoandrei/neovim](https://github.com/alfonsoandrei/neovim)) |
| `themes` | `~/.zsh2000-node/` | Zsh theme (submodule → [alfonsoandrei/zsh2000-node](https://github.com/alfonsoandrei/zsh2000-node)) |

Machine-specific config (credentials, work aliases, AWS/NATS/MongoDB) lives in `~/.zshrc.local` — not tracked by git.

---

## New machine setup

### 1. Clone the repo

```bash
git clone --recurse-submodules https://github.com/alfonsoandrei/dotfiles.git ~/dotfiles
```

> `--recurse-submodules` pulls the nvim config and zsh2000-node theme in one shot.

### 2. Run the bootstrap script

```bash
cd ~/dotfiles && ./install.sh
```

This will:
- Install Homebrew (if missing)
- Install all packages from `Brewfile`
- Install Oh My Zsh (if missing)
- Install `zsh-autosuggestions` and `zsh-syntax-highlighting` plugins
- Symlink all packages with `stow`
- Create `~/.zshrc.local` and `~/.gitconfig.local` from the example templates

### 3. Fill in local overrides

```bash
nvim ~/.zshrc.local      # credentials, work env vars, AWS/NATS/MongoDB functions
nvim ~/.gitconfig.local  # your name, email, GPG signing key
```

See [`zsh/.zshrc.local.example`](zsh/.zshrc.local.example) and [`git/.gitconfig.local.example`](git/.gitconfig.local.example) for all available options.

### 4. Restart your terminal

---

## Manual stow (skip install.sh)

If you already have Homebrew, Oh My Zsh, and `stow` installed:

```bash
cd ~/dotfiles

# Dry-run first to catch conflicts
stow --simulate zsh git config ssh scripts nvim themes

# Apply
stow zsh git config ssh scripts nvim themes
```

If stow reports conflicts (existing files at the target paths), back them up first:

```bash
mv ~/.zshrc ~/.zshrc.bak
mv ~/.gitconfig ~/.gitconfig.bak
# etc.
```

---

## Local overrides

Two files are sourced automatically but never committed:

| File | Purpose |
|------|---------|
| `~/.zshrc.local` | Credentials, work functions (AWS SSO, NATS, MongoDB), machine PATH additions |
| `~/.gitconfig.local` | Name, email, GPG signing key |

Copy the examples to get started:

```bash
cp ~/dotfiles/zsh/.zshrc.local.example ~/.zshrc.local
cp ~/dotfiles/git/.gitconfig.local.example ~/.gitconfig.local
```

---

## Adding a new config file

1. Create the stow package directory mirroring the home directory structure:
   ```bash
   mkdir -p ~/dotfiles/<package>/<path/relative/to/home>
   ```
2. Move the file in and stow it:
   ```bash
   mv ~/.<config> ~/dotfiles/<package>/.<config>
   stow <package>
   ```

Example — adding `~/.wezterm.lua`:
```bash
mv ~/.wezterm.lua ~/dotfiles/wezterm/.wezterm.lua
cd ~/dotfiles && stow wezterm
```

---

## Updating submodules

```bash
git submodule update --remote --merge
```

This pulls the latest commits from both the nvim config and zsh2000-node theme repos.
