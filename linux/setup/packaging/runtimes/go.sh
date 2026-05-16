#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing Go via mise..."
if mise list go 2>/dev/null | grep -qE '^go\s+'; then
  success "go already installed via mise"
else
  mise use -g go@latest
  success "go installed via mise"
fi
