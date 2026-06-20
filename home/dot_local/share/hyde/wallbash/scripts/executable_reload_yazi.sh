#!/usr/bin/env bash
# reload_yazi.sh — Post-processing hook for Yazi theme wallbash deployment
# Called after wallbash generates ~/.local/state/yazi/theme.toml

YAZI_STATE_DIR="${YAZI_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/yazi}"
YAZI_CONFIG_DIR="${YAZI_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/yazi}"
THEME_FILE="$YAZI_STATE_DIR/theme.toml"

if [[ ! -f "$THEME_FILE" ]]; then
    echo "[Yazi] Warning: theme.toml not found at $THEME_FILE" >&2
    exit 1
fi

# Ensure config dir exists and symlink is in place
mkdir -p "$YAZI_CONFIG_DIR"
ln -sf "$THEME_FILE" "$YAZI_CONFIG_DIR/theme.toml"

echo "[Yazi] Theme deployed to $THEME_FILE — symlinked from $YAZI_CONFIG_DIR/theme.toml"