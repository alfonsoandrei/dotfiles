#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=install/common.sh
source "$DOTFILES/install/common.sh"

for cmd in gpgconf gpg-connect-agent; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: '$cmd' not found. Run install.sh first." >&2
    exit 1
  fi
done

echo "==> Configuring gpg-agent..."
configure_gpg_agent

echo "==> Restarting gpg-agent..."
if ! gpgconf --kill gpg-agent; then
  echo "Warning: failed to stop gpg-agent, trying to start a fresh one..." >&2
fi

if ! gpg-connect-agent /bye >/dev/null; then
  echo "Error: failed to start gpg-agent with the updated config." >&2
  exit 1
fi

echo "✅ gpg-agent configured"
