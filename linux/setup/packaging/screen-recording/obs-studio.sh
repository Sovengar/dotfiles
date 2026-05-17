#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing OBS Studio..."

if _cmd_present obs || _cmd_present obs-studio; then
  success "OBS Studio already installed"
  return
fi

detect_pkg_manager >/dev/null
_ensure_sudo

case "$_pkg_manager" in
  pacman|apt|dnf)
    pkg_install obs-studio
    ;;
  brew)
    brew install --cask obs
    ;;
esac

success "OBS Studio installed"
