#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing Bluetooth stack..."

if pkg_is_installed bluez && pkg_is_installed blueman; then
  success "Bluetooth stack already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo

  case "$_pkg_manager" in
    pacman)
      pkg_install bluez bluez-utils blueman
      ;;
    apt)
      pkg_install bluez blueman
      ;;
    dnf)
      pkg_install bluez bluez-tools blueman
      ;;
    brew)
      log "Bluetooth system services are not managed by Homebrew on Linux, skipping"
      ;;
  esac

  success "Bluetooth stack installed"
fi
