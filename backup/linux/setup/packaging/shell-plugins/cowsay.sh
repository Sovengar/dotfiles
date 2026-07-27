#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing cowsay..."
if _cmd_present cowsay && _cmd_present cowthink; then
  success "cowsay already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  pkg_install cowsay
  success "cowsay installed"
fi
