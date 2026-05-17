#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Installing Dropbox..."

detect_pkg_manager >/dev/null

if _cmd_present dropbox; then
  success "dropbox already installed"
  return 0 2>/dev/null || exit 0
fi

case "$_pkg_manager" in
  apt)
    _ensure_sudo
    pkg_install dropbox python3-gpgme
    curl -fsL "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xz -C "$HOME"
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.dropbox-dist/dropboxd" "$HOME/.local/bin/dropbox"
    ;;
  pacman)
    _ensure_sudo
    pkg_install python-gpgme
    aur_install dropbox dropbox-cli
    systemctl --user enable --now dropbox.service || warn "Could not enable Dropbox user service; run 'dropbox start -i' manually"
    ;;
  dnf)
    _ensure_sudo
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
