#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing firefox..."

if _cmd_present firefox; then
  success "firefox already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  pkg_install firefox
  success "firefox installed"
fi
