#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing powerline-fonts..."

detect_pkg_manager >/dev/null
if pkg_is_installed powerline-fonts; then
  success "powerline-fonts already installed"
else
  _ensure_sudo
  pkg_install powerline-fonts
  success "powerline-fonts installed"
fi
