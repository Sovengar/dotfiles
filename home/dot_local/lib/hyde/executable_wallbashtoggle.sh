#!/usr/bin/env bash
[[ $HYDE_SHELL_INIT -ne 1 ]] && eval "$(hyde-shell init)"
paletteModes=("theme" "wallbash_auto" "wallbash_dark" "wallbash_light")
paletteLabels=("theme" "auto" "dark" "light")
rofi_wallbash() {
    pkill -u "$USER" rofi && exit 0
    font_scale=$ROFI_WALLBASH_MODE_SCALE
    [[ $font_scale =~ ^[0-9]+$ ]] || font_scale=${ROFI_SCALE:-10}
    r_scale="configuration {font: \"JetBrainsMono Nerd Font $font_scale\";}"
    elem_border=$((hypr_border * 4))
    r_override="window{border-radius:${elem_border}px;} element{border-radius:${elem_border}px;}"
    current_idx=0
    for i in "${!paletteModes[@]}"; do
        if [ "${paletteModes[i]}" == "${PALETTE_SOURCE:-theme}" ]; then
            current_idx=$i
            break
        fi
    done
    rofiSel=$(parallel echo {} ::: "${paletteLabels[@]}" | rofi -dmenu \
        -theme-str "$r_scale" \
        -theme-str "$r_override" \
        -theme wallbash \
        -select "${paletteLabels[$current_idx]}")
    if [ -n "$rofiSel" ]; then
        for i in "${!paletteLabels[@]}"; do
            if [ "${paletteLabels[i]}" == "$rofiSel" ]; then
                setMode="${paletteModes[i]}"
                break
            fi
        done
    else
        exit 0
    fi
}
step_wallbash() {
    local current="${PALETTE_SOURCE:-theme}"
    for i in "${!paletteModes[@]}"; do
        if [ "${paletteModes[i]}" == "$current" ]; then
            if [ "$1" == "n" ]; then
                local next=$(((i + 1) % ${#paletteModes[@]}))
                setMode="${paletteModes[next]}"
            elif [ "$1" == "p" ]; then
                local prev=$((i - 1))
                [ $prev -lt 0 ] && prev=$((${#paletteModes[@]} - 1))
                setMode="${paletteModes[prev]}"
            fi
            break
        fi
    done
}
case "$1" in
    m | -m | --menu) rofi_wallbash ;;
    n | -n | --next) step_wallbash n ;;
    p | -p | --prev) step_wallbash p ;;
    *) step_wallbash n ;;
esac
export reload_flag=1
[ -z "$setMode" ] && setMode="${PALETTE_SOURCE:-theme}"
set_conf "PALETTE_SOURCE" "$setMode"
"$LIB_DIR/hyde/theme.switch.sh"
notify-send -a "HyDE Alert" -i "$ICONS_DIR/Wallbash-Icon/hyde.png" " ${setMode} mode"
