#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../../helpers/all.sh"
fi

log "Installing lshw..."
if _cmd_present lshw; then
  success "lshw already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  pkg_install lshw
  success "lshw installed"
fi
