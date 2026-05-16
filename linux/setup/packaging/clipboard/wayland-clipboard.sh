#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing clipboard tools..."
detect_pkg_manager >/dev/null
_ensure_sudo

case "$_pkg_manager" in
  pacman)
    pkg_install cliphist wl-clip-persist wl-clipboard
    ;;
  apt|dnf|brew)
    pkg_install wl-clipboard
    log "cliphist/wl-clip-persist package names vary outside Arch; install them manually if needed"
    ;;
esac

success "Clipboard tools installed"
