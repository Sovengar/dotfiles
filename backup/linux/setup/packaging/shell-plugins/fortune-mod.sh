#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing fortune-mod..."
if _cmd_present fortune; then
  success "fortune-mod already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  pkg_install fortune-mod
  success "fortune-mod installed"
fi
