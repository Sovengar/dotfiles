#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing bat..."

if _cmd_present bat; then
  success "bat already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  pkg_install bat
  success "bat installed"
fi
