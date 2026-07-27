#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing ddcui..."

if _cmd_present ddcui; then
  success "ddcui already installed"
else
  aur_install ddcui
  success "ddcui installed"
fi
