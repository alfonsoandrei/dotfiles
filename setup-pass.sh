#!/usr/bin/env bash
set -e

STORE="$HOME/.password-store"

for cmd in pass gpg; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' not found. Run install.sh first." && exit 1
  fi
done

[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

if [ -d "$STORE" ]; then
  echo "~/.password-store already exists, nothing to do."
  exit 0
fi

if [ -z "$(gpg --list-secret-keys 2>/dev/null)" ]; then
  echo "Error: No GPG secret keys found. Run setup-yubikey.sh first." && exit 1
fi

if [ -n "$PASSWORD_STORE_REPO" ]; then
  git clone "$PASSWORD_STORE_REPO" "$STORE"
  echo "✅ Password store ready at ~/.password-store"
else
  echo "Error: PASSWORD_STORE_REPO is not set in ~/.zshrc.local" && exit 1
fi

echo "==> Configuring gpg2 for pass (macOS)..."
if command -v gpg2 &>/dev/null; then
  DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  for key_id in $(cat "$STORE"/.gpg-id 2>/dev/null); do
    if ! gpg2 -k "$key_id" &>/dev/null; then
      echo "   Importing public key $key_id into gpg2..."
      if gpg --export "$key_id" 2>/dev/null | gpg2 --import 2>/dev/null; then
        :
      elif [ -d "$DOTFILES/gnupg/public-keys" ]; then
        gpg2 --import "$DOTFILES/gnupg/public-keys"/*.asc 2>/dev/null || true
      fi
    fi
    echo "   Setting trust for $key_id in gpg2..."
    echo -e "trust\n5\ny\nsave" | gpg2 --batch --command-fd 0 --edit-key "$key_id" 2>/dev/null || true
  done
  echo "✅ gpg2 configured"
else
  echo "⚠️  gpg2 not found, pass may not work correctly on macOS"
fi
