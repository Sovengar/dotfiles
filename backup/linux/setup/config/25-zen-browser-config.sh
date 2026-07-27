#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Configuring Zen Browser..."

# 1. Set Zen as XDG default browser
if _cmd_present xdg-settings; then
  DESKTOP="zen.desktop"
  if [[ -f "/usr/share/applications/$DESKTOP" ]]; then
    xdg-settings set default-web-browser "$DESKTOP" 2>/dev/null || true
    xdg-mime default "$DESKTOP" x-scheme-handler/http 2>/dev/null || true
    xdg-mime default "$DESKTOP" x-scheme-handler/https 2>/dev/null || true
    xdg-mime default "$DESKTOP" text/html 2>/dev/null || true
    success "Zen set as default browser (XDG)"
  else
    warn "/usr/share/applications/$DESKTOP not found — XDG defaults not set"
  fi
else
  warn "xdg-settings not found — XDG defaults not set"
fi

# 2. Reload Hyprland if running
if hyprctl instances 2>/dev/null | grep -q .; then
  hyprctl reload 2>/dev/null || true
  log "Hyprland reloaded"
fi

success "Zen Browser configured"
