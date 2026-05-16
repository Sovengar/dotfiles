#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing SSH client..."
if _cmd_present ssh; then
  success "ssh already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  case "$_pkg_manager" in
    pacman) pkg_install openssh ;;
    apt) pkg_install openssh-client ;;
    dnf) pkg_install openssh-clients ;;
    brew) brew install openssh ;;
  esac
  success "ssh installed"
fi
