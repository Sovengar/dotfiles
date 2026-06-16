#!/usr/bin/env bash

wallbash_cache=${XDG_CACHE_HOME:-$HOME/.cache}/hyde/wallbash/qtct.conf

[[ -f "$wallbash_cache" ]] || { echo "Wallbash cache file not found at $wallbash_cache"; exit 1; }

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"

for scheme in qt5ct qt6ct; do
    state_path="$state_dir/$scheme/colors/wallbash.conf"
    mkdir -p "$(dirname "$state_path")"
    cp "$wallbash_cache" "$state_path"

    config_link="$config_dir/$scheme/colors/wallbash.conf"
    mkdir -p "$(dirname "$config_link")"
    ln -sf "$state_path" "$config_link"
done

