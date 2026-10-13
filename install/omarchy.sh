# Omarchy install steps. Sourced by install.sh.

install_omarchy_packages() {
  local packages=(
    bat
    eza
    fd
    fzf
    git-delta
    gnupg
    lazygit
    neovim
    pass
    pinentry
    ripgrep
    stow
    tmux
    wl-clipboard
    yazi
    yubikey-manager
    zoxide
    zsh
  )

  if ! command -v pacman >/dev/null 2>&1; then
    echo "Error: pacman was not found. This installer expects Omarchy/Arch Linux." >&2
    exit 1
  fi

  echo "==> Installing Omarchy packages..."
  if [ "$(id -u)" -eq 0 ]; then
    pacman -S --needed --noconfirm "${packages[@]}"
  elif command -v sudo >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm "${packages[@]}"
  else
    echo "Error: sudo is required to install packages." >&2
    exit 1
  fi
}

configure_omarchy_shell_handoff() {
  local bashrc marker_start marker_end
  bashrc="$HOME/.bashrc"
  marker_start="# >>> dotfiles omarchy zsh handoff >>>"
  marker_end="# <<< dotfiles omarchy zsh handoff <<<"

  touch "$bashrc"
  if grep -Fq "$marker_start" "$bashrc"; then
    return
  fi

  cat >>"$bashrc" <<'EOF'

# >>> dotfiles omarchy zsh handoff >>>
# Keep bash as the login shell for Omarchy startup, then hand off interactive shells to zsh.
if [[ $- == *i* ]] && [ -z "${BASH_EXECUTION_STRING:-}" ] && [ "${DOTFILES_NO_ZSH_HANDOFF:-0}" != "1" ]; then
  __dotfiles_parent_shell="$(ps --no-header --pid="$PPID" --format=comm 2>/dev/null || true)"
  if [ "$__dotfiles_parent_shell" != "zsh" ] && command -v zsh >/dev/null 2>&1; then
    exec "$(command -v zsh)"
  fi
  unset __dotfiles_parent_shell
fi
# <<< dotfiles omarchy zsh handoff <<<
EOF
}

echo_next_steps_omarchy() {
  echo ""
  echo "✅ Done! Next steps:"
  echo "   1. Restart your terminal and confirm it opens zsh"
  echo "   2. Edit ~/.zshrc.local and ~/.gitconfig.local"
  echo "   3. Plug in YubiKey and run: ./setup-yubikey.sh"
  echo "   4. Set PASSWORD_STORE_REPO in ~/.zshrc.local, then run: ./setup-pass.sh"
}

install_omarchy() {
  install_omarchy_packages
  install_omz
  install_zsh_plugins
  install_tmux_plugins
  init_submodules
  create_local_templates
  stow_dotfiles
  configure_gpg_agent
  configure_omarchy_shell_handoff
  echo_next_steps_omarchy
}
