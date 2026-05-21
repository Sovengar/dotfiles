#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing ttf-fantasque-nerd..."

detect_pkg_manager >/dev/null
if pkg_is_installed ttf-fantasque-nerd; then
  success "ttf-fantasque-nerd already installed"
else
  _ensure_sudo
  pkg_install ttf-fantasque-nerd
  success "ttf-fantasque-nerd installed"
fi
