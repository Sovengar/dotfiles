#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing duf..."

if _cmd_present duf; then
  success "duf already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  pkg_install duf
  success "duf installed"
fi
