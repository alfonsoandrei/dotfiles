#!/usr/bin/env bash
set -e

STORE="$HOME/.password-store"
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for cmd in pass gpg; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' not found. Run install.sh first." && exit 1
  fi
done

if [ -f "$HOME/.zshrc.local" ]; then
  PASSWORD_STORE_REPO="$(grep -E '^export PASSWORD_STORE_REPO=' "$HOME/.zshrc.local" | head -1 | sed 's/^export PASSWORD_STORE_REPO=//' | tr -d '"'"'")"
  GPG_KEY_ID="$(grep -E '^export GPG_KEY_ID=' "$HOME/.zshrc.local" | head -1 | sed 's/^export GPG_KEY_ID=//' | tr -d '"'"'")"
fi

NEW_SETUP=false
if [ ! -d "$STORE" ]; then
  if [ -z "$PASSWORD_STORE_REPO" ]; then
    echo "Error: PASSWORD_STORE_REPO is not set in ~/.zshrc.local" && exit 1
  fi
  echo "==> Cloning password store..."
  git clone "$PASSWORD_STORE_REPO" "$STORE"
  NEW_SETUP=true
fi

echo "==> Configuring gpg2 for pass (macOS)..."
if command -v gpg2 &>/dev/null; then
  KEY_IDS=()
  
  if [ -f "$STORE/.gpg-id" ]; then
    while IFS= read -r key_id; do
      KEY_IDS+=("$key_id")
    done < "$STORE/.gpg-id"
  fi
  
  if [ ${#KEY_IDS[@]} -eq 0 ] && [ -n "$GPG_KEY_ID" ]; then
    KEY_IDS=("$GPG_KEY_ID")
  fi
  
  for key_id in "${KEY_IDS[@]}"; do
    if ! gpg2 -k "$key_id" &>/dev/null; then
      echo "   Importing public key $key_id into gpg2..."
      if gpg --export "$key_id" 2>/dev/null | gpg2 --import 2>/dev/null; then
        :
      elif [ -d "$DOTFILES/gnupg/public-keys" ]; then
        for asc_file in "$DOTFILES/gnupg/public-keys"/*.asc; do
          [ -f "$asc_file" ] && gpg2 --import "$asc_file" 2>/dev/null || true
        done
      fi
    fi
    
    if gpg2 -k "$key_id" &>/dev/null; then
      echo "   Setting trust for $key_id in gpg2..."
      echo -e "trust\n5\ny\nsave" | gpg2 --batch --command-fd 0 --edit-key "$key_id" 2>/dev/null || true
    fi
  done
  
  if [ "$NEW_SETUP" = true ]; then
    echo "✅ Password store ready at ~/.password-store"
  fi
  echo "✅ gpg2 configured"
else
  echo "⚠️  gpg2 not found, pass may not work correctly on macOS"
fi

if [ "$NEW_SETUP" = true ]; then
  echo ""
  echo "Next steps:"
  echo "  1. Insert YubiKey with your GPG key"
  echo "  2. Test: pass test/password"
fi
