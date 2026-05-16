#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing screenshot tools..."
detect_pkg_manager >/dev/null
_ensure_sudo

case "$_pkg_manager" in
  pacman)
    pkg_install grim slurp satty hyprpicker
    ;;
  apt|dnf|brew)
    pkg_install grim slurp
    log "satty/hyprpicker package names vary outside Arch; install them manually if needed"
    ;;
esac

success "Screenshot tools installed"
