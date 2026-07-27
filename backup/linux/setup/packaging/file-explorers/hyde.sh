#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing HyDE file explorer..."

if _cmd_present dolphin; then
  success "HyDE file explorer already installed"
  return 0 2>/dev/null || exit 0
fi

detect_pkg_manager >/dev/null
_ensure_sudo
pkg_install dolphin
success "HyDE file explorer installed"
