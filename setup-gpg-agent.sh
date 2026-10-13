#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=install/common.sh
source "$DOTFILES/install/common.sh"

echo "==> Configuring gpg-agent..."
configure_gpg_agent

echo "==> Restarting gpg-agent..."
gpgconf --kill gpg-agent || true
gpg-connect-agent /bye >/dev/null 2>&1 || true

echo "✅ gpg-agent configured"
