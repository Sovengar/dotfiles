#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing clipboard tools..."
detect_pkg_manager >/dev/null

case "$_pkg_manager" in
  pacman)
    if _cmd_present cliphist && _cmd_present wl-clip-persist && _cmd_present wl-copy; then
      success "Clipboard tools already installed"
      return 0 2>/dev/null || exit 0
    fi
    _ensure_sudo
    pkg_install cliphist wl-clip-persist wl-clipboard
    ;;
  apt|dnf|brew)
    if _cmd_present wl-copy; then
      success "Clipboard tools already installed"
      return 0 2>/dev/null || exit 0
    fi
    _ensure_sudo
    pkg_install wl-clipboard
    log "cliphist/wl-clip-persist package names vary outside Arch; install them manually if needed"
    ;;
esac

success "Clipboard tools installed"
