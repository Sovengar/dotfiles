#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi

log "Installing git-absorb..."
if _cmd_present git-absorb; then
  success "git-absorb already installed"
elif pkg_install git-absorb 2>/dev/null; then
  success "git-absorb installed"
else
  warn "not in official repos"
  exit 1
fi