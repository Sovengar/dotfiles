#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Setting keyboard layout to Spanish..."

WAYLAND="${WAYLAND_DISPLAY:-}"
LAYOUT="es"

if [[ -n "$WAYLAND" ]] && _cmd_present hyprctl; then
  hyprctl keyword input:kb_layout "$LAYOUT" 2>/dev/null || true
  success "Keyboard layout set to $LAYOUT (Hyprland)"
elif _cmd_present setxkbmap; then
  setxkbmap "$LAYOUT"
  success "Keyboard layout set to $LAYOUT (X11)"
else
  warn "No hyprctl or setxkbmap found — keyboard layout not set"
  warn "Set manually: hyprctl keyword input:kb_layout $LAYOUT"
fi

# Also persist in Hyprland userprefs.conf if it exists
USERPREFS="$HOME/.config/hypr/userprefs.conf"
if [[ -f "$USERPREFS" ]]; then
  if ! grep -q "kb_layout.*$LAYOUT" "$USERPREFS" 2>/dev/null; then
    echo "input { kb_layout = $LAYOUT }" >> "$USERPREFS"
    success "Persisted keyboard layout in userprefs.conf"
  fi
fi

success "Keyboard configuration done"
