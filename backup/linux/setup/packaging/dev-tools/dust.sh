#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing dust..."
if _cmd_present dust; then
  success "dust already installed"
elif pkg_install dust 2>/dev/null; then
  success "dust installed"
else
  warn "not in official repos, falling back to cargo..."
  cargo install du-dust
  success "dust installed"
fi
