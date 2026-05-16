#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing IntelliJ IDEA..."
if _cmd_present idea || _cmd_present intellij-idea-community-edition; then
  success "IntelliJ IDEA already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  case "$_pkg_manager" in
    pacman) pkg_install intellij-idea-community-edition ;;
    *) pkg_install intellij-idea-community ;;
  esac
  success "IntelliJ IDEA installed"
fi
