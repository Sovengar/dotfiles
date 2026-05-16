#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing Bruno GUI..."
if _cmd_present bruno; then success "Bruno already installed"; else aur_install bruno-bin; success "Bruno installed"; fi
