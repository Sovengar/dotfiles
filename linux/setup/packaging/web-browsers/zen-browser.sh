#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing zen-browser..."

detect_pkg_manager >/dev/null

if _cmd_present zen-browser; then
  success "zen-browser already installed"
  return
fi

aur=""
if command -v paru &>/dev/null; then aur="paru"
elif command -v yay &>/dev/null; then aur="yay"
else err "No AUR helper found (paru/yay) — install one first"; exit 1
fi

log "Installing zen-browser-bin via $aur..."
$aur -S --noconfirm zen-browser-bin
success "zen-browser installed"
