#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi

log "Installing ec (easy-conflict)..."
if _cmd_present ec; then
  success "ec already installed"
else
  aur_install easy-conflict-bin
  success "ec installed"
fi