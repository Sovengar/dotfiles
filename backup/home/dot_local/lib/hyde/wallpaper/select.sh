#!/usr/bin/env bash

Wall_Select() {
    font_scale="$ROFI_WALLPAPER_SCALE"
    [[ $font_scale =~ ^[0-9]+$ ]] || font_scale=${ROFI_SCALE:-10}
    font_name=${ROFI_WALLPAPER_FONT:-$ROFI_FONT}
    font_name=${font_name:-$(get_hyprConf "MENU_FONT")}
    font_name=${font_name:-$(get_hyprConf "FONT")}
    font_override="* {font: \"${font_name:-"JetBrainsMono Nerd Font"} $font_scale\";}"
    elem_border=$((hypr_border * 3))

    if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        mon_data=$(hyprctl -j monitors)
        mon_x_res=$(jq '.[] | select(.focused==true) | if (.transform % 2 == 0) then .width else .height end' <<<"$mon_data")
        mon_y_res=$(jq '.[] | select(.focused==true) | if (.transform % 2 == 0) then .height else .width end' <<<"$mon_data")
        mon_scale=$(jq '.[] | select(.focused==true) | .scale' <<<"$mon_data" | sed "s/\.//")
    fi
    mon_x_res=${mon_x_res:-1920}
    mon_y_res=${mon_y_res:-1080}
    mon_scale=${mon_scale:-1}
    mon_x_res=$((mon_x_res * 100 / mon_scale))
    mon_y_res=$((mon_y_res * 100 / mon_scale))
    elm_width=$(((20 + 8 + 5) * font_scale))
    max_avail=$((mon_x_res - (4 * font_scale)))
    col_count=$((max_avail / elm_width))
    [[ -z ${HYPRLAND_INSTANCE_SIGNATURE} ]] && col_count=3
    [[ $col_count -gt 5 ]] && col_count=5
    max_rows=3
    r_override="window{width:100%;padding:0.5em;}
    listview{columns:${ROFI_WALLPAPER_COLUMN_COUNT:-${col_count:-3}};lines:${max_rows};spacing:3em;}
    element{border-radius:${elem_border}px;background-color:@main-bg;padding:0.3em;
    orientation:vertical;}
    element-icon{size:20em;border-radius:${elem_border}px;}
    element-text{padding:0.3em;}"
    local entry
    entry=$(Wall_Json | jq -r '.[].rofi_sqre' | rofi -dmenu \
        -display-column-separator ":::" \
        -display-columns 1 \
        -theme-str "$font_override" \
        -theme-str "$r_override" \
        -theme "${ROFI_WALLPAPER_STYLE:-selector}" \
        -l "${max_rows}" \
        -fixed-num-lines \
        -select "$(basename "$(readlink "$wallSet")")")
    selected_thumbnail="$(awk -F ':::' '{print $3}' <<<"$entry")"
    selected_wallpaper_path="$(awk -F ':::' '{print $2}' <<<"$entry")"
    selected_wallpaper="$(awk -F ':::' '{print $1}' <<<"$entry")"
    export selected_wallpaper selected_wallpaper_path selected_thumbnail
    if [ -z "$selected_wallpaper" ]; then
        print_log -err "wallpaper" " No wallpaper selected"
        exit 0
    fi
}
