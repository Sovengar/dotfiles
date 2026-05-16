#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing Visual Studio Code..."
if _cmd_present code || _cmd_present code-oss; then
  success "VS Code already installed"
else
  detect_pkg_manager >/dev/null
  case "$_pkg_manager" in
    pacman) aur_install visual-studio-code-bin ;;
    *) _ensure_sudo; pkg_install code ;;
  esac
  success "VS Code installed"
fi
