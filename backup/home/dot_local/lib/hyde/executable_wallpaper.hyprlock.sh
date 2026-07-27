#!/usr/bin/env bash
[[ $HYDE_SHELL_INIT -ne 1 ]] && eval "$(hyde-shell init)"

selected_wall="$1"
[ -z "$selected_wall" ] && selected_wall="${XDG_STATE_HOME:-$HOME/.local/state}/hyprlock/wallpaper"
selected_wall="$(readlink -f "$selected_wall")"
[ -f "$selected_wall" ] || exit 1

hyprlock_state_home="${XDG_STATE_HOME:-$HOME/.local/state}/hyprlock"
mkdir -p "$hyprlock_state_home"
ln -sfn "$selected_wall" "$hyprlock_state_home/wallpaper"

if file --mime-type -b "$selected_wall" | grep -q '^video/'; then
    mkdir -p "$HYDE_CACHE_HOME/wallpapers/thumbnails"
    cached_thumb="$HYDE_CACHE_HOME/wallpapers/$(${hashMech:-sha1sum} "$selected_wall" | cut -d' ' -f1).png"
    extract_thumbnail "$selected_wall" "$cached_thumb"
    selected_wall="$cached_thumb"
fi

cp -f "$selected_wall" "$hyprlock_state_home/wallpaper.png"
