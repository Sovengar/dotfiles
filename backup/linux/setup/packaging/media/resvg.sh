#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing resvg..."
if _cmd_present resvg; then
  success "resvg already installed"
  return 0 2>/dev/null || exit 0
fi
if ! _cmd_present cargo; then
  err "cargo is required to install resvg"
  return 1 2>/dev/null || exit 1
fi
cargo install resvg
success "resvg installed"
