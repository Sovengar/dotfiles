#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

if _cmd_present spotify-adblock; then
  success "spotify-adblock already installed"
  return
fi

# spotify-adblock depends on spotify; spotify is in chaotic-aur but
# the package file is often 404 on mirrors. Install from AUR directly.
if ! pacman -Q spotify &>/dev/null; then
  log "Installing spotify from AUR (bypassing broken chaotic-aur package)..."
  paru -S --noconfirm --skipreview --provides="aur/spotify" spotify 2>/dev/null || {
    # If provider prompt still blocks, try with explicit provider number
    echo "1" | paru -S --noconfirm --skipreview spotify
  }
  success "spotify installed"
fi

log "Installing spotify-adblock..."
aur_install spotify-adblock
success "spotify-adblock installed"
