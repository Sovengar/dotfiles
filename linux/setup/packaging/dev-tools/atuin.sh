#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing atuin..."
if _cmd_present atuin; then
  success "atuin already installed"
elif pkg_install atuin 2>/dev/null; then
  success "atuin installed"
else
  warn "not in official repos, falling back to cargo..."
  cargo install atuin
  success "atuin installed"
fi
