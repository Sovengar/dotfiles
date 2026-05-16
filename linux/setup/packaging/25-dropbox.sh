#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Installing Dropbox..."

detect_pkg_manager >/dev/null
_ensure_sudo

if _cmd_present dropbox; then
  success "dropbox already installed"
  return
fi

case "$_pkg_manager" in
  apt)
    pkg_install dropbox python3-gpgme
    curl -fsL "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xz -C "$HOME"
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.dropbox-dist/dropboxd" "$HOME/.local/bin/dropbox"
    ;;
  pacman)
    pkg_install dropbox dropbox-cli python-gpgme
    sudo systemctl enable --now dropboxd
    ;;
  dnf)
    pkg_install dropbox python3-gpgme
    curl -fsL "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xz -C "$HOME"
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.dropbox-dist/dropboxd" "$HOME/.local/bin/dropbox"
    ;;
  brew)
    brew install --cask dropbox
    ;;
esac

success "dropbox installed. Run 'dropbox start -i' to authenticate"
