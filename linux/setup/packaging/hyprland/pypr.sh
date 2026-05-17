#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing pyprland..."

if _cmd_present pypr; then
  success "pyprland already installed"
  return 0 2>/dev/null || exit 0
fi

aur_install pyprland
success "pyprland installed"
