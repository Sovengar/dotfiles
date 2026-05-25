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

if _cmd_present code-oss; then
  _vscode_bin="code-oss"
elif _cmd_present code; then
  _vscode_bin="code"
else
  warn "VS Code command not found; skipping extensions"
  return 0
fi

_wallbash_extension="TheHyDEProject.wallbash"
if "$_vscode_bin" --list-extensions 2>/dev/null | grep -qi "^${_wallbash_extension}$"; then
  success "Wallbash extension already installed"
elif "$_vscode_bin" --install-extension "$_wallbash_extension" --force; then
  success "Wallbash extension installed"
else
  warn "Could not install ${_wallbash_extension}; install it manually if the extension gallery is unavailable"
fi
