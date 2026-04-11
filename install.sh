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

# ── 3. Zsh plugins ──────────────────────────────────────────────────────────
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

# ── 5. Stow symlinks ────────────────────────────────────────────────────────
echo "==> Symlinking dotfiles with stow..."
cd "$DOTFILES"
for pkg in zsh git config ssh scripts nvim themes; do
    echo "   stow $pkg"
    stow -t "$HOME" --restow "$pkg"
done

# ── 6. Local override templates ─────────────────────────────────────────────
if [ ! -f "$HOME/.zshrc.local" ]; then
    echo "==> Creating ~/.zshrc.local from example..."
    cp "$DOTFILES/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
    echo "   ⚠️  Fill in your credentials in ~/.zshrc.local"
fi

if [ ! -f "$HOME/.gitconfig.local" ]; then
    echo "==> Creating ~/.gitconfig.local from example..."
    cp "$DOTFILES/git/.gitconfig.local.example" "$HOME/.gitconfig.local"
    echo "   ⚠️  Fill in your name, email, and GPG key in ~/.gitconfig.local"
fi

echo ""
echo "✅ Done! Next steps:"
echo "   1. Edit ~/.zshrc.local — add credentials and work-specific config"
echo "   2. Edit ~/.gitconfig.local — add your name, email, and GPG signing key"
echo "   3. Restart your terminal"
