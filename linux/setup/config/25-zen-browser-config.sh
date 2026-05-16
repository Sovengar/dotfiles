#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Configuring Zen Browser..."

# 1. Create run-browser wrapper (zen with firefox fallback)
WRAPPER="$HOME/.local/bin/run-browser"
if [[ -f "$WRAPPER" ]]; then
  log "run-browser wrapper already exists"
else
  mkdir -p "$HOME/.local/bin"
  cat > "$WRAPPER" <<'EOF'
#!/usr/bin/env bash
if command -v zen-browser &>/dev/null; then
    exec zen-browser "$@"
else
    exec firefox "$@"
fi
EOF
  chmod +x "$WRAPPER"
  success "Created run-browser wrapper at $WRAPPER"
fi

# 2. Override $BROWSER in userprefs.conf (HyDE's user override file)
USERPREFS="$HOME/.config/hypr/userprefs.conf"
if [[ -f "$USERPREFS" ]]; then
  if grep -q '^\$BROWSER' "$USERPREFS" 2>/dev/null; then
    log "\$BROWSER already set in userprefs.conf"
  else
    echo "" >> "$USERPREFS"
    echo "# Browser override — uses zen-browser with firefox fallback" >> "$USERPREFS"
    echo '$BROWSER = hyde-shell open --fall run-browser web-browser' >> "$USERPREFS"
    success "Set \$BROWSER = run-browser in userprefs.conf"
  fi
else
  warn "userprefs.conf not found — \$BROWSER not set"
fi

# 3. Set Zen as XDG default browser
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

# 4. Reload Hyprland if running
if hyprctl instances 2>/dev/null | grep -q .; then
  hyprctl reload 2>/dev/null || true
  log "Hyprland reloaded"
fi

success "Zen Browser configured (SUPER+B uses run-browser)"
