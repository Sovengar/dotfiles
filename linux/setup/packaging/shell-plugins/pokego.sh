#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing pokego..."

if _cmd_present pokego; then
  success "pokego already installed"
else
  aur_install pokego-bin
  success "pokego installed"
fi
