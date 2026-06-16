#!/usr/bin/env bash
[[ $HYDE_SHELL_INIT -ne 1 ]] && eval "$(hyde-shell init)"
[ -f "${XDG_STATE_HOME:-$HOME/.local/state}/hypr/shader.conf" ] && source "${XDG_STATE_HOME:-$HOME/.local/state}/hypr/shader.conf"
confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
dataDir="${XDG_DATA_HOME:-$HOME/.local/share}"
cacheDir="${XDG_CACHE_HOME:-$HOME/.cache}"
user_shaders_dir="$confDir/hypr/shaders"
data_shaders_dir="${HYPR_DATA_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/hypr}/shaders"
cache_shaders_dir="$cacheDir/hypr/shaders"
if [ ! -d "$user_shaders_dir" ] && [ ! -d "$data_shaders_dir" ]; then
    send_notifs -i "preferences-desktop-display" "Error" "No shaders directory exists at $user_shaders_dir or $data_shaders_dir"
    exit 1
fi
show_help() {
    cat <<HELP
Usage: $0 [OPTIONS]

Options:
    --select | -S       Select a shader from the available options
    --reload | -r       Reload the current shader
    --help   | -h       Show this help message
HELP
}
if [ -z "$*" ]; then
    echo "No arguments provided"
    show_help
fi
LONG_OPTS="select,help,reload"
SHORT_OPTS="Shr"
PARSED=$(getopt --options $SHORT_OPTS --longoptions "$LONG_OPTS" --name "$0" -- "$@")
if [ $? -ne 0 ]; then
    exit 2
fi
eval set -- "$PARSED"
if [ -z "$1" ]; then
    echo "No arguments provided"
    show_help
    exit 1
fi
fn_select() {
    shader_items=$(find -L "$data_shaders_dir" "$user_shaders_dir" -maxdepth 1 -name "*.frag" ! -name "disable.frag" -print0 2>/dev/null | xargs -r -0 -n1 basename | sed 's/\.frag$//' | sort -u)
    if [ -f "$user_shaders_dir/disable.frag" ] || [ -f "$data_shaders_dir/disable.frag" ]; then
        shader_items="disable\n$shader_items"
    fi
    if [ -z "$shader_items" ]; then
        send_notifs -i "preferences-desktop-display" "Error" "No .frag files found in $user_shaders_dir or $data_shaders_dir"
        exit 1
    fi
    font_scale="$ROFI_SHADER_SCALE"
    [[ $font_scale =~ ^[0-9]+$ ]] || font_scale=${ROFI_SCALE:-10}
    font_name=${ROFI_SHADER_FONT:-$ROFI_FONT}
    font_name=${font_name:-$(get_hyprConf "MENU_FONT")}
    font_name=${font_name:-$(get_hyprConf "FONT")}
    font_override="* {font: \"${font_name:-\"JetBrainsMono Nerd Font\"} $font_scale\";}"
    hypr_border=${hypr_border:-"$(hyprctl -j getoption decoration:rounding | jq '.int')"}
    wind_border=$((hypr_border * 3 / 2))
    elem_border=$((hypr_border == 0 ? 5 : hypr_border))
    hypr_width=${hypr_width:-"$(hyprctl -j getoption general:border_size | jq '.int')"}
    r_override="window{border:${hypr_width}px;border-radius:${wind_border}px;} wallbox{border-radius:${elem_border}px;} element{border-radius:${elem_border}px;}"
    selected_shader=$(echo -e "$shader_items" | rofi -dmenu -i -select "$HYPR_SHADER" \
        -p "Select shader" \
        -theme-str 'entry { placeholder: "🎨 Select shader..."; }' \
        -theme-str "$font_override" \
        -theme-str "$r_override" \
        -theme-str "$(get_rofi_pos)" \
        -theme "clipboard")
    if [ -z "$selected_shader" ]; then
        exit 0
    fi
    set_conf "HYPR_SHADER" "$selected_shader"
    fn_update "$selected_shader" && hyprctl reload
    send_notifs -i "preferences-desktop-display" "Shader:" "$selected_shader"
}
fn_reload() {
    if [ -z "$HYPR_SHADER" ]; then
        HYPR_SHADER="disable"
    fi
    set_conf "HYPR_SHADER" "$HYPR_SHADER"
    fn_update "$HYPR_SHADER" && hyprctl reload
    send_notifs -i "preferences-desktop-display" "Shader reloaded:" "$HYPR_SHADER"
}
shader_file() {
    local selected_shader="$1"
    if [ -f "$user_shaders_dir/$selected_shader.frag" ]; then
        printf '%s\n' "$user_shaders_dir/$selected_shader.frag"
        return 0
    fi
    if [ -f "$data_shaders_dir/$selected_shader.frag" ]; then
        printf '%s\n' "$data_shaders_dir/$selected_shader.frag"
        return 0
    fi
    return 1
}
concat_shader_files() {
    local files=("$@")
    local version_directive=""
    local compiled_file="$cache_shaders_dir/.compiled.cache.glsl"
    local main_frag_file="${files[-1]}"
    if [ -f "$main_frag_file" ]; then
        version_directive=$(grep -E '^\s*#version\s+' "$main_frag_file" | head -n1)
        if [ -n "$version_directive" ]; then
            print_log -g "Found version directive" " $version_directive"
        else
            print_log -y "Warning" " No #version directive found in $main_frag_file"
            version_directive="#version 300 es"
        fi
    fi
    mkdir -p "$cache_shaders_dir"
    echo "$version_directive" >"$compiled_file"
    echo "" >>"$compiled_file"
    for f in "${files[@]}"; do
        if [ -f "$f" ]; then
            print_log -g "Processing shader" " file: $f"
            sed '/^\s*#version\s/d' "$f" >>"$compiled_file"
            echo "" >>"$compiled_file"
        fi
    done
}
parse_includes_and_update() {
    local selected_shader="$1"
    local files=()
    local main_frag_file
    main_frag_file=$(shader_file "$selected_shader") || {
        send_notifs -i "preferences-desktop-display" "Error" "Shader not found: $selected_shader"
        return 1
    }
    local source_var
    source_var=$(grep -iE '^\s*//\s*!source\s*=\s*.*' "$main_frag_file" 2>/dev/null | head -n1 | sed -E 's/^\s*\/\/\s*!source\s*=\s*//I' | xargs)
    if [ -n "$source_var" ]; then
        source_var=$(eval echo "$source_var")
        if [ -f "$source_var" ]; then
            files+=("$source_var")
            print_log -g "Found source include" " $source_var"
        else
            print_log -y "Warning" " Source file not found: $source_var"
        fi
    fi
    local inc_file="$user_shaders_dir/$selected_shader.inc"
    if [ -f "$inc_file" ]; then
        files+=("$inc_file")
        print_log -g "Found inc file" " $inc_file"
    fi
    files+=("$main_frag_file")
    if concat_shader_files "${files[@]}"; then
        print_log -g "Shader" " $selected_shader compiled successfully."
    else
        print_log -r "Error" " Failed to compile shader $selected_shader"
        return 1
    fi
    hypr_generated_dir="${HYPR_GENERATED_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/hypr}"
    mkdir -p "$hypr_generated_dir"
    cat <<EOF >"$hypr_generated_dir/shaders.conf"

#! █▀ █░█ ▄▀█ █▀▄ █▀▀ █▀█ █▀
#! ▄█ █▀█ █▀█ █▄▀ ██▄ █▀▄ ▄█

# Generated by shaders.sh // Read-only
# Manual edits are not visible until you run: hyprctl reload

# *┌────────────────────────────────────────────────────────────────────────────┐
# *│                                                                            |
# *│ HyDE Controlled content DO NOT EDIT!                                      |
# *│ Add custom shaders/overrides in \$XDG_CONFIG_HOME/hypr/shaders            |
# *│ Built-in shaders live in \$HYPR_DATA_HOME/shaders                        |
# *│ and run the 'shaders.sh --select' command to update this file             |
# *│ Modify ./shaders/shader-name.inc to add your own custom defines         |
# *│ The 'shader.sh' script will automatically compile this file to the cache  |
# *│ and the cache will be used in the shader                                  |
# *│                                                                            |
# *└────────────────────────────────────────────────────────────────────────────┘

# name of the shader
\$SCREEN_SHADER = "$selected_shader"
# path to the shader
\$SCREEN_SHADER_PATH = "$main_frag_file"
# path to the compiled shader // override in the shader-specific config/state
\$SCREEN_SHADER_COMPILED = $cache_shaders_dir/.compiled.cache.glsl


EOF
}
fn_update() {
    parse_includes_and_update "$1"
}
while true; do
    case "$1" in
    -S | --select)
        fn_select
        exit 0
        ;;
    -r | --reload)
        fn_reload
        exit 0
        ;;
    --help | -h)
        show_help
        exit 0
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Invalid option: $1"
        show_help
        exit 1
        ;;
    esac
done
