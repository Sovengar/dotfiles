#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing Node.js and npm via mise..."
if mise list node 2>/dev/null | grep -qE '^node\s+'; then
  success "node already installed via mise"
else
  mise use -g node@lts
  success "node installed via mise"
fi
