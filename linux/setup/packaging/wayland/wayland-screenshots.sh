#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing screenshot tools..."
detect_pkg_manager >/dev/null

case "$_pkg_manager" in
  pacman)
    if _cmd_present grim && _cmd_present slurp && _cmd_present satty && _cmd_present hyprpicker; then
      success "Screenshot tools already installed"
      return 0 2>/dev/null || exit 0
    fi
    _ensure_sudo
    pkg_install grim slurp satty hyprpicker
    ;;
  apt|dnf|brew)
    if _cmd_present grim && _cmd_present slurp; then
      success "Screenshot tools already installed"
      return 0 2>/dev/null || exit 0
    fi
    _ensure_sudo
    pkg_install grim slurp
    log "satty/hyprpicker package names vary outside Arch; install them manually if needed"
    ;;
esac

success "Screenshot tools installed"
