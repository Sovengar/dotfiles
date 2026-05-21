#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing pipes.sh..."
if _cmd_present pipes.sh; then
  success "pipes.sh already installed"
else
  aur_install pipes.sh
  success "pipes.sh installed"
fi
