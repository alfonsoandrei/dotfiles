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

install_ghostty_nvim_opener() {
  local app="$HOME/Applications/Ghostty Nvim.app"
  local lsregister=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister

  echo "==> Building Ghostty Nvim.app and making it the plain-text handler..."
  mkdir -p "$HOME/Applications"
  rm -rf "$app"
  osacompile -o "$app" "$DOTFILES/install/ghostty-nvim.applescript"
  plutil -replace CFBundleIdentifier -string "local.dotfiles.ghostty-nvim" "$app/Contents/Info.plist"
  plutil -replace CFBundleDocumentTypes -json \
    '[{"CFBundleTypeName":"Plain text","CFBundleTypeRole":"Editor","LSHandlerRank":"Alternate","LSItemContentTypes":["public.plain-text"]}]' \
    "$app/Contents/Info.plist"
  # Editing Info.plist invalidates osacompile's signature.
  codesign --force --sign - "$app"
  "$lsregister" -f "$app"
  duti -s local.dotfiles.ghostty-nvim public.plain-text all
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
  install_nvm
  install_neovim_node_deps
  init_submodules
  create_local_templates
  mkdir -p "$HOME/.ssh/config.d"
  chmod 700 "$HOME/.ssh" "$HOME/.ssh/config.d"
  PACKAGES+=(macos-ssh macos-mdfried macos-lazygit)
  stow_dotfiles
  install_yazi_packages
  build_bat_cache
  install_omz
  install_zsh_plugins
  configure_gpg_agent
  install_ghostty_nvim_opener
  apply_macos_defaults
  echo_next_steps
}
