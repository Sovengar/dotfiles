#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing hollywood..."
if _cmd_present hollywood; then
  success "hollywood already installed"
else
  aur_install hollywood
  success "hollywood installed"
fi
