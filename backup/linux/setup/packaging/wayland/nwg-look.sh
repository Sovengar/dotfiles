#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing nwg-look..."

if _cmd_present nwg-look; then
  success "nwg-look already installed"
  return 0 2>/dev/null || exit 0
fi

detect_pkg_manager >/dev/null
_ensure_sudo
pkg_install nwg-look
success "nwg-look installed"
