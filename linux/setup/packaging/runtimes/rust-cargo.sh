#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing Rust and Cargo via mise..."
if mise list rust 2>/dev/null | grep -qE '^rust\s+'; then
  success "rust already installed via mise"
else
  mise use -g rust@latest
  success "rust/cargo installed via mise"
fi
