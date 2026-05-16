#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Setting up Gemini floating web app..."

GEMINI_ICON_URL="https://ssl.gstatic.com/images/branding/product/2x/gemini_48dp.png"
ICON_DIR="${HOME}/.local/share/icons/hicolor/48x48/apps"
ICON_PATH="${ICON_DIR}/gemini.png"
DESKTOP_ENTRY="${HOME}/.local/share/applications/gemini.desktop"
LAUNCHER="${HOME}/.local/bin/gemini-app"
PYPR_CONF="${HOME}/.config/hypr/pyprland.conf"
KEYBIND_CONF="${HOME}/.config/hypr/keybindings.overrides.conf"

mkdir -p "${ICON_DIR}" "${HOME}/.local/bin" "$(dirname "$DESKTOP_ENTRY")"

# 1. Download icon
log "Downloading Gemini icon..."
if [[ -f "$ICON_PATH" ]]; then
  log "Icon already exists, skipping download"
else
  curl -sLo "${ICON_PATH}" "${GEMINI_ICON_URL}"
  if file "${ICON_PATH}" 2>/dev/null | grep -q "PNG"; then
    success "Icon downloaded"
    gtk-update-icon-cache "${HOME}/.local/share/icons/hicolor/" 2>/dev/null || true
  else
    warn "Icon download may have failed"
  fi
fi

# 2. Create launcher script
log "Creating launcher script..."
if [[ -f "$LAUNCHER" ]]; then
  log "Launcher already exists"
else
  cat > "${LAUNCHER}" <<'EOF'
#!/bin/bash
exec pypr toggle gemini
EOF
  chmod +x "${LAUNCHER}"
  success "Launcher created: ${LAUNCHER}"
fi

# 3. Create desktop entry
log "Creating desktop entry..."
if [[ -f "$DESKTOP_ENTRY" ]]; then
  log "Desktop entry already exists"
else
  cat > "${DESKTOP_ENTRY}" <<'EOF'
[Desktop Entry]
Name=Gemini
Comment=Google Gemini AI - Floating Web App
Exec=pypr toggle gemini
Icon=gemini
Type=Application
Categories=Network;WebBrowser;
Terminal=false
StartupWMClass=firefox
Keywords=gemini;ai;google;
EOF
  success "Desktop entry created"
fi

# 4. pypr scratchpad config is managed by chezmoi.
log "Gemini pypr scratchpad is managed by chezmoi"

# 5. Keybindings are managed by chezmoi.
log "Gemini keybinding is managed by chezmoi"

# 6. Reload configs
log "Reloading configs..."
if pgrep -x pypr &>/dev/null; then
  pypr reload 2>/dev/null && success "pypr reloaded" || warn "pypr reload failed"
else
  pypr &>/dev/null &
  sleep 1
  log "pypr daemon started"
fi
if command -v hyprctl &>/dev/null; then
  hyprctl reload 2>/dev/null || true
fi
update-desktop-database "${HOME}/.local/share/applications/" 2>/dev/null || true

success "Gemini floating web app ready (SUPER+F)"
