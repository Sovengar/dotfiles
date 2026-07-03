#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing Plex Media Server..."

if _cmd_present plexmediaserver; then
  success "Plex Media Server already installed"
else
  pkg_install plex-media-server
  success "Plex Media Server installed"
fi
