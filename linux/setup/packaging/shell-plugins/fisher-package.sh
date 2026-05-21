#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing fisher package..."

detect_pkg_manager >/dev/null
if pkg_is_installed fisher; then
  success "fisher package already installed"
else
  _ensure_sudo
  pkg_install fisher
  success "fisher package installed"
fi
