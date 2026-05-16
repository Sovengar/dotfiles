#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing Google Antigravity..."
if _cmd_present antigravity; then
  success "Google Antigravity already installed"
else
  aur_install google-antigravity
  success "Google Antigravity installed"
fi
