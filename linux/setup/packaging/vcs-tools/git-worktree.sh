#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Checking git worktree support..."
if git worktree --help >/dev/null 2>&1; then
  success "git worktree available"
else
  err "git worktree is not available; update git"
  exit 1
fi
