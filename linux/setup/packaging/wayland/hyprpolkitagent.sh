#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing hyprpolkitagent..."

detect_pkg_manager >/dev/null
if pkg_is_installed hyprpolkitagent; then
  success "hyprpolkitagent already installed"
  return 0 2>/dev/null || exit 0
fi

_ensure_sudo
pkg_install hyprpolkitagent
success "hyprpolkitagent installed"
