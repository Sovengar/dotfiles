#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing qBittorrent..."

if _cmd_present qbittorrent; then
  success "qBittorrent already installed"
  return 0 2>/dev/null || exit 0
fi

detect_pkg_manager >/dev/null
_ensure_sudo
pkg_install qbittorrent
success "qBittorrent installed"
