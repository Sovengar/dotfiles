#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing wf-recorder..."

if _cmd_present wf-recorder; then
  success "wf-recorder already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  pkg_install wf-recorder
  success "wf-recorder installed"
fi
