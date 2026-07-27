#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing cbonsai..."
if _cmd_present cbonsai; then
  success "cbonsai already installed"
else
  aur_install cbonsai
  success "cbonsai installed"
fi
