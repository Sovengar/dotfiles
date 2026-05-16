#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing JetBrainsMono Nerd Font..."

if fc-match "JetBrainsMono Nerd Font" 2>/dev/null | grep -qi "JetBrains"; then
  success "JetBrainsMono Nerd Font already installed"
  return
fi

detect_pkg_manager >/dev/null
case "$_pkg_manager" in
  pacman)
    _ensure_sudo
    pkg_install ttf-jetbrains-mono-nerd
    ;;
  apt|dnf)
    _ensure_sudo
    pkg_install unzip fontconfig
    font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
    mkdir -p "$font_dir"
    tmp_zip="/tmp/JetBrainsMono.zip"
    curl -fsL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" -o "$tmp_zip"
    unzip -o "$tmp_zip" -d "$font_dir" >/dev/null
    fc-cache -f "$font_dir"
    ;;
  brew)
    brew tap homebrew/cask-fonts || true
    brew install --cask font-jetbrains-mono-nerd-font
    ;;
esac

success "JetBrainsMono Nerd Font installed"
