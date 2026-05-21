#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing fish-pure-prompt..."

detect_pkg_manager >/dev/null
if pkg_is_installed fish-pure-prompt; then
  success "fish-pure-prompt already installed"
else
  _ensure_sudo
  pkg_install fish-pure-prompt
  success "fish-pure-prompt installed"
fi
