#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../../helpers/all.sh"
fi

log "Installing zsh-history-substring-search..."

detect_pkg_manager >/dev/null
if pkg_is_installed zsh-history-substring-search; then
  success "zsh-history-substring-search already installed"
else
  _ensure_sudo
  pkg_install zsh-history-substring-search
  success "zsh-history-substring-search installed"
fi
