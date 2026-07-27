#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../../helpers/all.sh"
fi

log "Installing zsh-theme-powerlevel10k..."

detect_pkg_manager >/dev/null
if pkg_is_installed zsh-theme-powerlevel10k; then
  success "zsh-theme-powerlevel10k already installed"
else
  _ensure_sudo
  pkg_install zsh-theme-powerlevel10k
  success "zsh-theme-powerlevel10k installed"
fi
