#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing Beekeeper Studio..."
if _cmd_present beekeeper-studio; then success "Beekeeper Studio already installed"; else aur_install beekeeper-studio-bin; success "Beekeeper Studio installed"; fi
