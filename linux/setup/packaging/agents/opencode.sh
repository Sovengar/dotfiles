#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing opencode..."
if _cmd_present opencode; then
  success "opencode already installed"
else
  if ! _cmd_present brew; then
    err "Homebrew is required to install opencode"
    exit 1
  fi
  brew install sst/tap/opencode
  success "opencode installed"
fi
