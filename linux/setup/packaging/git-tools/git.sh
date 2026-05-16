#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing git..."
if _cmd_present git; then
  success "git already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  pkg_install git
  success "git installed"
fi
