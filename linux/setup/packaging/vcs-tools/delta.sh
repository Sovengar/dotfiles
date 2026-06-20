#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi

log "Installing delta (git-delta)..."
if _cmd_present delta; then
  success "delta already installed"
elif pkg_install git-delta 2>/dev/null; then
  success "delta installed"
else
  warn "not in official repos"
  exit 1
fi