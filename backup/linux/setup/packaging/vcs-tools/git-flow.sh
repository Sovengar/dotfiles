#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing git-flow..."

if _cmd_present git-flow; then
  success "git-flow already installed"
  exit 0
fi

detect_pkg_manager >/dev/null

if [[ "$_pkg_manager" != "brew" ]]; then
  _ensure_sudo
fi

case "$_pkg_manager" in
  pacman) pkg_install gitflow-avh ;;
  brew) brew install git-flow ;;
  *) pkg_install git-flow ;;
esac

success "git-flow installed"
