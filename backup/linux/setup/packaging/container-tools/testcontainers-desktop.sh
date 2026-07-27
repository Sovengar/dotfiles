#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing Testcontainers Desktop..."
if _cmd_present testcontainers-desktop; then
  success "testcontainers-desktop already installed"
else
  local_tmp="$(mktemp -d)"
  curl -fsSL https://app.testcontainers.cloud/download/testcontainers-desktop_linux_x86-64.deb -o "$local_tmp/testcontainers-desktop.deb"

  # Extract .deb (ar + zstd tar)
  pushd "$local_tmp" >/dev/null
  ar x testcontainers-desktop.deb
  if command -v zstd &>/dev/null; then
    tar --zstd -xf data.tar.zst
  else
    zstd -d data.tar.zst -o data.tar && tar xf data.tar
  fi
  popd >/dev/null

  # Install binary
  mkdir -p "$HOME/.local/bin"
  cp "$local_tmp/opt/testcontainers-desktop/bin/testcontainers-desktop" "$HOME/.local/bin/"
  chmod +x "$HOME/.local/bin/testcontainers-desktop"

  # Install icons
  local_icons="$HOME/.local/share/icons/hicolor"
  for res in 16x16 32x32 48x48 64x64 128x128 256x256 scalable; do
    if [[ -f "$local_tmp/usr/share/icons/hicolor/$res/apps/testcontainers-desktop.png" ]]; then
      mkdir -p "$local_icons/$res/apps"
      cp "$local_tmp/usr/share/icons/hicolor/$res/apps/testcontainers-desktop.png" "$local_icons/$res/apps/"
    fi
  done
  if [[ -f "$local_tmp/usr/share/icons/hicolor/scalable/apps/testcontainers-desktop.svg" ]]; then
    mkdir -p "$local_icons/scalable/apps"
    cp "$local_tmp/usr/share/icons/hicolor/scalable/apps/testcontainers-desktop.svg" "$local_icons/scalable/apps/"
  fi

  # Create desktop entry
  mkdir -p "$HOME/.local/share/applications"
  cat > "$HOME/.local/share/applications/testcontainers-desktop.desktop" <<EOF
[Desktop Entry]
Name=Testcontainers Desktop
Comment=Testcontainers Desktop application
Exec=$HOME/.local/bin/testcontainers-desktop
Icon=testcontainers-desktop
Terminal=false
Type=Application
Categories=Development;
StartupNotify=true
EOF

  rm -rf "$local_tmp"
  success "testcontainers-desktop installed"
fi
