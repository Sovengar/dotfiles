#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Configuring KeePassXC autostart..."

if ! _cmd_present keepassxc; then
  warn "KeePassXC not installed — skipping autostart config"
  return
fi

# KeePassXC system tray settings
KEEPASSXC_CONFIG="$HOME/.config/keepassxc/keepassxc.ini"
mkdir -p "$(dirname "$KEEPASSXC_CONFIG")"

if [[ ! -f "$KEEPASSXC_CONFIG" ]]; then
  cat > "$KEEPASSXC_CONFIG" <<'EOF'
[General]
ShowTrayIcon=true
MinimizeToTray=true
EOF
  log "Created KeePassXC tray config"
fi

# Autostart in Hyprland
USERPREFS="$HOME/.config/hypr/userprefs.conf"
if [[ -f "$USERPREFS" ]]; then
  if ! grep -q "exec-once.*keepassxc" "$USERPREFS" 2>/dev/null; then
    echo "exec-once = keepassxc" >> "$USERPREFS"
    success "Added keepassxc autostart to $USERPREFS"
  else
    log "KeePassXC autostart already configured"
  fi
else
  log "Hyprland userprefs.conf not found — skipping autostart config"
fi

success "KeePassXC autostart configured"
