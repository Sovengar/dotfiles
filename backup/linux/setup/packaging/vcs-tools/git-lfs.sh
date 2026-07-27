#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing git-lfs..."
if _cmd_present git-lfs; then
  success "git-lfs already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  pkg_install git-lfs
  success "git-lfs installed"
fi
