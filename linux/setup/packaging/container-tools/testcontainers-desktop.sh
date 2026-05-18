#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing Testcontainers Desktop..."
if _cmd_present testcontainers-desktop; then
  success "testcontainers-desktop already installed"
else
  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://testcontainers.com/desktop/download/linux -o "$HOME/.local/bin/testcontainers-desktop"
  chmod +x "$HOME/.local/bin/testcontainers-desktop"
  mkdir -p "$HOME/.local/share/applications"
  cat > "$HOME/.local/share/applications/testcontainers-desktop.desktop" <<EOF
[Desktop Entry]
Name=Testcontainers Desktop
GenericName=Testcontainers Companion App
Comment=Manage and freeze your test containers
Exec=$HOME/.local/bin/testcontainers-desktop
Icon=docker
Type=Application
Categories=Development;ComputerScience;
Terminal=false
StartupNotify=true
EOF
  success "testcontainers-desktop installed"
fi
