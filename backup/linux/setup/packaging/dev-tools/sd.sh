#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing sd..."
if _cmd_present sd; then
  success "sd already installed"
elif pkg_install sd 2>/dev/null; then
  success "sd installed"
else
  warn "not in official repos, falling back to cargo..."
  cargo install sd
  success "sd installed"
fi
