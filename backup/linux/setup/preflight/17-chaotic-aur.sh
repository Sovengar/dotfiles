#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Setting up Chaotic-AUR..."

if ! command -v pacman &>/dev/null; then
  log "pacman not found, skipping Chaotic-AUR"
  return
fi

if grep -q '^\[chaotic-aur\]' /etc/pacman.conf 2>/dev/null; then
  success "Chaotic-AUR already configured"
  return 0 2>/dev/null || exit 0
fi

_ensure_sudo

sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

sudo pacman -U --noconfirm \
  'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
  'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf

sudo pacman -Syy

success "Chaotic-AUR configured"
