#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing DBeaver..."
if _cmd_present dbeaver; then
  success "DBeaver already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  case "$_pkg_manager" in
    pacman) pkg_install dbeaver ;;
    apt) pkg_install dbeaver-ce ;;
    dnf) pkg_install dbeaver ;;
    brew) brew install --cask dbeaver-community ;;
  esac
  success "DBeaver installed"
fi
