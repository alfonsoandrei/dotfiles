# Shared install steps. Sourced by install.sh.

PACKAGES=(zsh git config ssh scripts nvim-lite themes opencode tmux gnupg)

install_omz() {

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "==> Installing Oh My Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
}

install_neovim_node_deps() {
  local deps

  echo "==> Installing Neovim Node.js dependencies..."
  deps=(neovim tree-sitter-cli eslint_d @mermaid-js/mermaid-cli)

  if npm install -g "${deps[@]}"; then
    return
  fi

  echo "   Retrying with user prefix at $HOME/.local (fixes npm global EACCES)..."
  npm install --prefix "$HOME/.local" -g "${deps[@]}"
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

configure_gpg_agent() {
  local gpg_home conf pinentry tmp
  gpg_home="${GNUPGHOME:-$HOME/.gnupg}"
  conf="$gpg_home/gpg-agent.conf"
  pinentry="$HOME/.local/bin/pinentry-auto"

  if [ ! -x "$pinentry" ]; then
    echo "Error: $pinentry is missing. Stow the scripts package first." >&2
    exit 1
  fi

  # Older Stow layouts could leave ~/.gnupg as a dangling symlink.
  if [ -L "$gpg_home" ] && [ ! -d "$gpg_home" ]; then
    rm -f "$gpg_home"
  fi

  mkdir -p "$gpg_home"
  chmod 700 "$gpg_home"

  # gpg-agent does not expand ~. Missing files (including dangling legacy links)
  # get the template. Existing files keep every other setting.
  if [ ! -e "$conf" ]; then
    rm -f "$conf"
    sed "s|__PINENTRY__|$pinentry|" "$DOTFILES/install/gpg-agent.conf.in" > "$conf"
  else
    tmp="$(mktemp)"
    awk -v pin="$pinentry" '
      BEGIN { found_pin = 0; found_ssh = 0 }
      /^[[:space:]]*enable-ssh-support([[:space:]]|$)/ {
        found_ssh = 1
      }
      /^[[:space:]]*pinentry-program[[:space:]]/ {
        if (!found_pin) {
          print "pinentry-program " pin
          found_pin = 1
        }
        next
      }
      { print }
      END {
        if (!found_pin) print "pinentry-program " pin
        if (!found_ssh) print "enable-ssh-support"
      }
    ' "$conf" > "$tmp"
    if [ -L "$conf" ]; then
      cat "$tmp" > "$conf"
      rm -f "$tmp"
    else
      mv "$tmp" "$conf"
    fi
  fi
  chmod 600 "$conf"
}

ensure_dotfiles_link() {
  local home_dotfiles existing
  home_dotfiles="$HOME/dotfiles"

  if [ -L "$home_dotfiles" ] || [ -d "$home_dotfiles" ]; then
    if existing="$(cd "$home_dotfiles" 2>/dev/null && pwd -P)"; then
      if [ "$existing" != "$DOTFILES" ]; then
        echo "Error: $home_dotfiles points to $existing, expected $DOTFILES." >&2
        exit 1
      fi
      return
    fi
  fi

  if [ -e "$home_dotfiles" ]; then
    echo "Error: $home_dotfiles exists and is not a directory/symlink to this repo." >&2
    exit 1
  fi

  ln -s "$DOTFILES" "$home_dotfiles"
}

stow_dotfiles() {
  local pkg failed=0

  if ! command -v stow >/dev/null 2>&1; then
    echo "Error: stow is not installed." >&2
    exit 1
  fi

  echo "==> Checking dotfiles for stow conflicts..."
  ensure_dotfiles_link

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
