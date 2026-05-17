#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Setting up lazydocker floating TUI..."

DESKTOP_ENTRY="${HOME}/.local/share/applications/lazydocker.desktop"
ICON_DIR="${HOME}/.local/share/applications/icons"
ICON_URL="https://raw.githubusercontent.com/docker/compose/main/logo.png"
PYPR_CONF="${HOME}/.config/hypr/pyprland.conf"
KEYBIND_CONF="${HOME}/.config/hypr/keybindings.overrides.conf"

mkdir -p "$ICON_DIR" "$(dirname "$DESKTOP_ENTRY")"

if [[ -f "${ICON_DIR}/lazydocker.png" ]]; then
  log "lazydocker icon already exists"
else
  curl -sLo "${ICON_DIR}/lazydocker.png" "$ICON_URL"
fi

cat > "$DESKTOP_ENTRY" <<EOF
[Desktop Entry]
Version=1.0
Name=lazydocker
Comment=Docker TUI
Exec=pypr toggle lazydocker
Terminal=false
Type=Application
Icon=${ICON_DIR}/lazydocker.png
StartupNotify=true
EOF
chmod +x "$DESKTOP_ENTRY"
update-desktop-database "${HOME}/.local/share/applications/" 2>/dev/null || true
success "lazydocker rofi entry configured"

log "lazydocker pypr scratchpad is managed by chezmoi"

log "lazydocker keybinding is managed by chezmoi"
