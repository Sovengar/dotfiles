#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing Datree..."
if _cmd_present datree; then success "datree already installed"; else curl -fsL https://get.datree.io | /bin/bash; success "datree installed"; fi
