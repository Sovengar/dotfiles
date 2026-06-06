#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing xh..."
if _cmd_present xh; then
  success "xh already installed"
elif pkg_install xh 2>/dev/null; then
  success "xh installed"
else
  warn "not in official repos, falling back to cargo..."
  cargo install xh
  success "xh installed"
fi
