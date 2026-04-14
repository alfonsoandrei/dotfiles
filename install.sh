#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Starting dotfiles setup..."

# ── 1. Homebrew ─────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH for Apple Silicon
  eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
fi

echo "==> Installing packages from Brewfile..."
brew bundle --file="$DOTFILES/Brewfile"

# ── 2. Oh My Zsh ────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ── 3. NVM ──────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.nvm" ]; then
  echo "==> Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  # Export for current session to allow further setup if needed
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  # Install LTS by default
  nvm install --lts
fi

# ── 4. Zsh plugins ──────────────────────────────────────────────────────────
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "==> Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "==> Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ── 4. Submodules (nvim config + zsh2000-node theme) ────────────────────────
echo "==> Updating git submodules..."
git -C "$DOTFILES" submodule update --init --recursive

# ── 5. Local override templates ─────────────────────────────────────────────
if [ ! -f "$DOTFILES/zsh/.zshrc.local" ]; then
  echo "==> Creating zsh/.zshrc.local from example..."
  cp "$DOTFILES/zsh/.zshrc.local.example" "$DOTFILES/zsh/.zshrc.local"
  echo "   ⚠️  Fill in your credentials in ~/.zshrc.local"
fi

if [ ! -f "$DOTFILES/git/.gitconfig.local" ]; then
  echo "==> Creating git/.gitconfig.local from example..."
  cp "$DOTFILES/git/.gitconfig.local.example" "$DOTFILES/git/.gitconfig.local"
  echo "   ⚠️  Fill in your name, email, and GPG key in ~/.gitconfig.local"
fi

# ── 6. Stow symlinks ────────────────────────────────────────────────────────
echo "==> Symlinking dotfiles with stow..."
cd "$DOTFILES"

# Back up any real files that would conflict with stow (e.g. ~/.zshrc from OMZ)
REAL_DOTFILES="$(realpath "$DOTFILES")"
for pkg in zsh git config ssh scripts nvim themes opencode gnupg; do
  find "$DOTFILES/$pkg" -not -type d 2>/dev/null | while IFS= read -r src; do
    rel="${src#$DOTFILES/$pkg/}"
    target="$HOME/$rel"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      # Check if the file is already part of the dotfiles repo (e.g., via a parent directory symlink)
      if [[ "$(realpath "$target" 2>/dev/null)" == "$REAL_DOTFILES"* ]]; then
        continue
      fi
      echo "   backing up $target -> $target.bak"
      mv "$target" "$target.bak"
    fi
  done
done

for pkg in zsh git config ssh scripts nvim themes opencode gnupg; do
  echo "   stow $pkg"
  stow -t "$HOME" --restow "$pkg"
done

# ── 7. Migrate Ghostty config to XDG path ───────────────────────────────────
GHOSTTY_LEGACY="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
GHOSTTY_XDG="$HOME/.config/ghostty/config"
if [ -f "$GHOSTTY_LEGACY" ] && [ ! -L "$GHOSTTY_LEGACY" ] && [ ! -e "$GHOSTTY_XDG" ]; then
  echo "==> Migrating Ghostty config to ~/.config/ghostty/config..."
  mkdir -p "$HOME/.config/ghostty"
  mv "$GHOSTTY_LEGACY" "$GHOSTTY_XDG.bak"
fi

# ── 8. Symlink Zsh theme ────────────────────────────────────────────────────
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/themes"
if [ ! -L "$ZSH_CUSTOM/themes/zsh2000-node.zsh-theme" ]; then
  echo "==> Symlinking zsh2000-node theme to Oh My Zsh..."
  ln -sf "$HOME/.zsh2000-node/zsh2000-node.zsh-theme" "$ZSH_CUSTOM/themes/zsh2000-node.zsh-theme"
fi

echo ""
echo "✅ Done! Next steps:"
echo "   1. Edit ~/.zshrc.local — add credentials and work-specific config"
echo "   2. Edit ~/.gitconfig.local — add your name, email, and GPG signing key"
echo "   3. Restart your terminal"
