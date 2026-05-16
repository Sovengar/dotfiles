#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing WebCord..."

if _cmd_present webcord; then
  success "WebCord already installed"
  return
fi

detect_pkg_manager >/dev/null

case "$_pkg_manager" in
  pacman)
    aur_install webcord-bin
    ;;
  apt|dnf|brew)
    if command -v flatpak &>/dev/null; then
      flatpak install -y flathub io.github.spacingbat3.webcord
    else
      warn "WebCord is not available via $_pkg_manager; install flatpak or use Arch/AUR"
      return
    fi
    ;;
esac

success "WebCord installed"
