#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../../helpers/all.sh"
fi

log "Installing oh-my-zsh-git..."

detect_pkg_manager >/dev/null
if pkg_is_installed oh-my-zsh-git; then
  success "oh-my-zsh-git already installed"
else
  _ensure_sudo
  pkg_install oh-my-zsh-git
  success "oh-my-zsh-git installed"
fi
