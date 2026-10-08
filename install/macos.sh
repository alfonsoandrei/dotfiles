# macOS install steps. Sourced by install.sh.

install_brew() {

  if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
  fi

  echo "==> Installing packages from Brewfile..."
  brew bundle --file="$DOTFILES/Brewfile"
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

apply_macos_defaults() {
  echo "==> Applying macOS defaults..."
  defaults write -g NSWindowShouldDragOnGesture -bool true
}

echo_next_steps() {

  echo ""
  echo "✅ Done! Next steps:"
  echo "   1. Edit ~/.zshrc.local — add credentials and work-specific config"
  echo "   2. Edit ~/.gitconfig.local — add your name, email, and GPG signing key"
  echo "   3. Restart your terminal (macOS defaults applied)"
  echo "   4. Plug in YubiKey and run: ./setup-yubikey.sh"
  echo "   5. Set PASSWORD_STORE_REPO in ~/.zshrc.local, then run: ./setup-pass.sh"
}

install_macos() {
  install_brew
  install_omz
  install_nvm
  install_neovim_node_deps
  install_zsh_plugins
  install_tmux_plugins
  init_submodules
  create_local_templates
  stow_dotfiles
  apply_macos_defaults
  echo_next_steps
}
