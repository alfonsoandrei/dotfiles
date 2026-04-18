#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh git config ssh scripts nvim themes opencode tmux gnupg)

install_brew() {

  if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
  fi

  echo "==> Installing packages from Brewfile..."
  brew bundle --file="$DOTFILES/Brewfile"
}

install_omz() {

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "==> Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
}

install_nvm() {

  if [ ! -d "$HOME/.nvm" ]; then
    echo "==> Installing NVM..."

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    nvm install --lts
  fi
}

install_neovim_node_deps() {

  echo "==> Installing Neovim Node.js dependencies..."
  npm install -g neovim tree-sitter-cli eslint_d @mermaid-js/mermaid-cli
}

install_zsh_plugins() {
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "==> Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  fi

  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "==> Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  fi

  if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "==> Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  fi
}

install_tmux_plugins() {
  TMUX_PLUGINS="$HOME/.tmux/plugins"

  clone_if_missing() {
    local name="$1" url="$2"
    if [ ! -d "$TMUX_PLUGINS/$name" ]; then
      echo "==> Installing tmux plugin: $name..."
      git clone "$url" "$TMUX_PLUGINS/$name"
    fi
  }

  clone_if_missing tpm               https://github.com/tmux-plugins/tpm
  clone_if_missing tmux-sensible     https://github.com/tmux-plugins/tmux-sensible
  clone_if_missing tmux-resurrect    https://github.com/tmux-plugins/tmux-resurrect
  clone_if_missing tmux-continuum    https://github.com/tmux-plugins/tmux-continuum
  clone_if_missing vim-tmux-navigator https://github.com/christoomey/vim-tmux-navigator
  clone_if_missing tmux              https://github.com/rose-pine/tmux
}

init_submodules() {
  echo "==> Updating git submodules..."

  git -C "$DOTFILES" submodule update --init --recursive
}

create_local_templates() {

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
}

stow_dotfiles() {

  echo "==> Symlinking dotfiles with stow..."
  ln -sf "$DOTFILES" "$HOME/dotfiles"
  cd "$DOTFILES"

  # Adopt existing files into repo, then restore repo versions
  for pkg in "${PACKAGES[@]}"; do
    stow -t "$HOME" --adopt "$pkg" 2>/dev/null || true
  done
  git -C "$DOTFILES" checkout -- .

  for pkg in "${PACKAGES[@]}"; do
    echo "   stow $pkg"
    stow -t "$HOME" --restow "$pkg"
  done

}

echo_next_steps() {

  echo ""
  echo "✅ Done! Next steps:"
  echo "   1. Edit ~/.zshrc.local — add credentials and work-specific config"
  echo "   2. Edit ~/.gitconfig.local — add your name, email, and GPG signing key"
  echo "   3. Restart your terminal"
  echo "   4. Plug in YubiKey and run: ./setup-yubikey.sh"
  echo "   5. Set PASSWORD_STORE_REPO in ~/.zshrc.local, then run: ./setup-pass.sh"
}

main() {

  echo "==> Starting dotfiles setup..."

  install_brew
  install_omz
  install_nvm
  install_neovim_node_deps
  install_zsh_plugins
  install_tmux_plugins
  init_submodules
  create_local_templates
  stow_dotfiles

  echo_next_steps
}

main
