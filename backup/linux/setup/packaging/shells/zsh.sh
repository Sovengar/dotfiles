#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing zsh..."

if _cmd_present zsh; then
  success "zsh already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  pkg_install zsh
  success "zsh installed"
fi
