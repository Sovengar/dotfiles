#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing gh-copilot..."
if gh extension list 2>/dev/null | grep -q '^gh copilot'; then log "gh-copilot already installed"; else gh extension install github/gh-copilot; success "gh-copilot installed"; fi
