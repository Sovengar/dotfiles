#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing Java runtime via mise..."
if mise list java 2>/dev/null | grep -qE '^java\s+'; then
  success "java already installed via mise"
else
  mise use -g java@latest
  success "java installed via mise"
fi
