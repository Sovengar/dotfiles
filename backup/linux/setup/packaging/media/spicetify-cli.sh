#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing spicetify-cli..."

if _cmd_present spicetify; then
  success "spicetify-cli already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  pkg_install spicetify-cli
  success "spicetify-cli installed"
fi
