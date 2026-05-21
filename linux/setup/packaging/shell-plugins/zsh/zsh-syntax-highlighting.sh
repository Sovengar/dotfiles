#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../../helpers/all.sh"
fi

log "Installing zsh-syntax-highlighting..."

detect_pkg_manager >/dev/null
if pkg_is_installed zsh-syntax-highlighting; then
  success "zsh-syntax-highlighting already installed"
else
  _ensure_sudo
  pkg_install zsh-syntax-highlighting
  success "zsh-syntax-highlighting installed"
fi
