#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing fish-autopair..."

detect_pkg_manager >/dev/null
if pkg_is_installed fish-autopair; then
  success "fish-autopair already installed"
else
  _ensure_sudo
  pkg_install fish-autopair
  success "fish-autopair installed"
fi
