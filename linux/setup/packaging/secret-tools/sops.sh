#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing SOPS..."

if _cmd_present sops; then
  success "SOPS already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  pkg_install sops
  success "SOPS installed"
fi
