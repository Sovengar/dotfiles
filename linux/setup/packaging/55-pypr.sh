#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Installing pyprland..."

if _cmd_present pypr; then
  success "pyprland already installed"
  return
fi

local aur=""
if command -v paru &>/dev/null; then aur="paru"
elif command -v yay &>/dev/null; then aur="yay"
else err "No AUR helper found (paru/yay) — install one first"; exit 1
fi

$aur -S --noconfirm pyprland
success "pyprland installed"
