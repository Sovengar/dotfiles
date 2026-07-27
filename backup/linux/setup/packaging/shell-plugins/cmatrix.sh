#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing cmatrix..."
if _cmd_present cmatrix; then success "cmatrix already installed"; else pkg_install cmatrix; success "cmatrix installed"; fi
