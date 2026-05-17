#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Setting up tui-generator..."

TUI_GENERATOR="${HOME}/.local/bin/tui-generator.sh"
DESKTOP_ENTRY="${HOME}/.local/share/applications/tui-generator.desktop"
APPLICATIONS_DIR="${HOME}/.local/share/applications"
ICON_DIR="${APPLICATIONS_DIR}/icons"

mkdir -p "${HOME}/.local/bin" "$ICON_DIR" "$APPLICATIONS_DIR"

cat > "$TUI_GENERATOR" <<'SCRIPT'
#!/bin/bash

set -euo pipefail

ICON_DIR="$HOME/.local/share/applications/icons"

if (( $# != 4 )); then
  echo -e "\e[32mCreate a TUI shortcut for the app launcher (Super+A).\n\e[0m"
  APP_NAME=$(gum input --prompt "Name> " --placeholder "My TUI")
  APP_EXEC=$(gum input --prompt "Launch Command> " --placeholder "lazydocker or bash -c 'dust; read -n 1 -s'")
  WINDOW_STYLE=$(gum choose --header "Window style" float tile)
  ICON_URL=$(gum input --prompt "Icon URL> " --placeholder "See https://dashboardicons.com (must use PNG or SVG!)")
else
  APP_NAME="$1"
  APP_EXEC="$2"
  WINDOW_STYLE="$3"
  ICON_URL="$4"
fi

if [[ -z $APP_NAME || -z $APP_EXEC || -z $ICON_URL ]]; then
  echo "You must set app name, app command, and icon URL!"
  exit 1
fi

# Resolve brew binaries to full path (needed for xdg-terminal-exec)
CMD="${APP_EXEC%% *}"
if ! command -v "$CMD" &>/dev/null; then
  BREW_BIN="/home/linuxbrew/.linuxbrew/bin/$CMD"
  if [[ -f "$BREW_BIN" ]]; then
    ARGS="${APP_EXEC#$CMD}"
    APP_EXEC="$BREW_BIN$ARGS"
  fi
fi

DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"

if [[ ! $ICON_URL =~ ^https?:// ]] && [[ -f $ICON_URL ]]; then
  ICON_PATH="$ICON_URL"
else
  ICON_PATH="$ICON_DIR/$APP_NAME.png"
  mkdir -p "$ICON_DIR"
  if ! curl -sL -o "$ICON_PATH" "$ICON_URL"; then
    echo "Error: Failed to download icon."
    exit 1
  fi
fi

if [[ $WINDOW_STYLE == "float" ]]; then
  APP_CLASS="TUI.float"
else
  APP_CLASS="TUI.tile"
fi

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$APP_NAME
Exec=xdg-terminal-exec --app-id=$APP_CLASS -e $APP_EXEC
Terminal=false
Type=Application
Icon=$ICON_PATH
StartupNotify=true
EOF

chmod +x "$DESKTOP_FILE"
update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true

if (( $# != 4 )); then
  echo -e "You can now find $APP_NAME using the app launcher (Super+A)\n"
fi
SCRIPT

chmod +x "$TUI_GENERATOR"

cat > "$DESKTOP_ENTRY" <<EOF
[Desktop Entry]
Version=1.0
Name=TUI Generator
Comment=Create TUI launchers for rofi
Exec=xdg-terminal-exec --app-id=TUI.float -e ${TUI_GENERATOR}
Terminal=false
Type=Application
Icon=utilities-terminal
Categories=Utility;System;
Keywords=tui;terminal;launcher;rofi;
StartupNotify=true
EOF

chmod +x "$DESKTOP_ENTRY"
update-desktop-database "$APPLICATIONS_DIR" 2>/dev/null || true

success "tui-generator installed with rofi launcher"
