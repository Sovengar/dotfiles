#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing NetworkManager..."

if pkg_is_installed networkmanager || pkg_is_installed network-manager; then
  success "NetworkManager already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo

  case "$_pkg_manager" in
    pacman)
      pkg_install networkmanager network-manager-applet
      ;;
    apt)
      pkg_install network-manager network-manager-gnome
      ;;
    dnf)
      pkg_install NetworkManager NetworkManager-applet
      ;;
    brew)
      log "NetworkManager is not managed by Homebrew on Linux, skipping"
      ;;
  esac

  success "Network packages installed"
fi
