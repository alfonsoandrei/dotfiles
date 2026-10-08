#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=install/common.sh
source "$DOTFILES/install/common.sh"

detect_platform() {
  local uname_s os_release
  uname_s="$(uname -s)"
  os_release="${DOTFILES_OS_RELEASE:-/etc/os-release}"

  if [ "$uname_s" = "Darwin" ]; then
    echo macos
    return
  fi

  if [ "$uname_s" = "Linux" ] && [ -f "$os_release" ] && grep -qi omarchy "$os_release"; then
    echo omarchy
    return
  fi

  echo unsupported
}

main() {
  local platform
  platform="$(detect_platform)"

  echo "==> Starting dotfiles setup ($platform)..."

  case "$platform" in
    macos)
      # shellcheck source=install/macos.sh
      source "$DOTFILES/install/macos.sh"
      install_macos
      ;;
    omarchy)
      # shellcheck source=install/omarchy.sh
      source "$DOTFILES/install/omarchy.sh"
      install_omarchy
      ;;
    *)
      echo "Error: unsupported platform ($platform)." >&2
      exit 1
      ;;
  esac
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main
fi
