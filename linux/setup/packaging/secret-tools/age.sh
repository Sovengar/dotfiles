#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing age..."

if _cmd_present age; then
  success "age already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  pkg_install age
  success "age installed"
fi
