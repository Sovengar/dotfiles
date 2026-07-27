#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing lazydocker..."

if _cmd_present lazydocker; then
  log "lazydocker already installed"
else
  log "Installing lazydocker via brew..."
  brew install lazydocker
  success "lazydocker installed"
fi
