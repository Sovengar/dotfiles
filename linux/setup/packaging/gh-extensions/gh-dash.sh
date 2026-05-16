#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing gh-dash..."
if gh extension list 2>/dev/null | grep -q '^gh dash'; then log "gh-dash already installed"; else gh extension install dlvhdr/gh-dash; success "gh-dash installed"; fi
