#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing Spotify..."

if _cmd_present spotify; then
  success "Spotify already installed"
else
  aur_install spotify
  success "Spotify installed"
fi
