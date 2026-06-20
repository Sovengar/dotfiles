#!/usr/bin/env bash
# reload_yazi.sh — Post-processing hook for Yazi theme wallbash deployment
# Called after wallbash generates ~/.config/yazi/theme.toml
#
# Yazi does not currently support hot-reload of theme changes.
# The theme will take effect on the next Yazi launch.
# This script can be extended if Yazi adds signal-based or IPC reload in the future.

YAZI_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/yazi"
THEME_FILE="$YAZI_CONFIG_DIR/theme.toml"

if [[ ! -f "$THEME_FILE" ]]; then
    echo "[Yazi] Warning: theme.toml not found at $THEME_FILE" >&2
    exit 1
fi

echo "[Yazi] Theme deployed to $THEME_FILE — restart Yazi to see changes"