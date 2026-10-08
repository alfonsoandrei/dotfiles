# Shared install steps. Sourced by install.sh.

PACKAGES=(zsh git config ssh scripts nvim-lite themes opencode tmux gnupg)

install_omz() {

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "==> Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
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

  clone_if_missing tpm https://github.com/tmux-plugins/tpm
  clone_if_missing tmux-sensible https://github.com/tmux-plugins/tmux-sensible
  clone_if_missing tmux-resurrect https://github.com/tmux-plugins/tmux-resurrect
  clone_if_missing tmux-continuum https://github.com/tmux-plugins/tmux-continuum
  clone_if_missing vim-tmux-navigator https://github.com/christoomey/vim-tmux-navigator
  clone_if_missing tmux https://github.com/rose-pine/tmux
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
  local pkg failed=0

  if ! command -v stow >/dev/null 2>&1; then
    echo "Error: stow is not installed." >&2
    exit 1
  fi

  echo "==> Checking dotfiles for stow conflicts..."
  ln -sf "$DOTFILES" "$HOME/dotfiles"

  for pkg in "${PACKAGES[@]}"; do
    if ! stow -n -d "$DOTFILES" -t "$HOME" "$pkg"; then
      failed=1
    fi
  done

  if [ "$failed" -ne 0 ]; then
    echo "Error: stow found conflicts. Move the existing files aside, then re-run ./install.sh." >&2
    exit 1
  fi

  echo "==> Symlinking dotfiles with stow..."
  for pkg in "${PACKAGES[@]}"; do
    echo "   stow $pkg"
    stow -d "$DOTFILES" -t "$HOME" --restow "$pkg"
  done
}
