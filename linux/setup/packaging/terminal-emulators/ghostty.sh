#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing ghostty..."

if _cmd_present ghostty; then
  success "ghostty already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo

  if [[ "$(get_distro)" == "arch" ]]; then
    pkg_install ghostty
  else
    pkg_install ghostty
  fi

  success "ghostty installed"
fi
