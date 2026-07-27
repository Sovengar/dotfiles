#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing wtype (Wayland keystroke injector)..."

if _cmd_present wtype; then
  success "wtype already installed"
  return 0 2>/dev/null || exit 0
fi

pkg_install wtype
success "wtype installed"
