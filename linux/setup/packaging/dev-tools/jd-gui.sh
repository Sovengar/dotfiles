#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing JD-GUI..."
if _cmd_present jd-gui; then success "JD-GUI already installed"; else aur_install jd-gui-bin; success "JD-GUI installed"; fi
