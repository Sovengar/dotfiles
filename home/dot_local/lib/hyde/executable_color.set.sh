#!/usr/bin/env bash
[[ $HYDE_SHELL_INIT -ne 1 ]] && eval "$(hyde-shell init)"
[[ -n $HYPRLAND_INSTANCE_SIGNATURE ]] && {
    hyprctl keyword misc:disable_autoreload 1 -q
    trap "hyprctl reload config-only -q" EXIT
}
load_dconf_kdeglobals() {
    source "$LIB_DIR/hyde/color/hypr.sh"
    source "$LIB_DIR/hyde/color/dconf.sh"
    toml_write "$XDG_CONFIG_HOME/kdeglobals" "Colors:View" "BackgroundNormal" "#${dcol_pry1:-000000}FF"
    toml_write "$XDG_CONFIG_HOME/Kvantum/wallbash/wallbash.kvconfig" '%General' 'reduce_menu_opacity' 0
    [[ -n $HYPRLAND_INSTANCE_SIGNATURE ]] && shaders.sh reload
}
create_wallbash_substitutions() {
    local use_inverted=$1
    local sed_script
    sed_script="s|<wallbash_mode>|$($use_inverted && printf "%s" "${dcol_invt:-light}" || printf "%s" "${dcol_mode:-dark}")|g;"
    for i in {1..4}; do
        if $use_inverted; then
            rev_i=$((5 - i))
            src_i=$rev_i
        else
            src_i=$i
        fi
        local pry_var="dcol_pry$src_i"
        local txt_var="dcol_txt$src_i"
        local pry_rgba_var="dcol_pry${src_i}_rgba"
        local txt_rgba_var="dcol_txt${src_i}_rgba"
        local pry_rgb_var="dcol_pry${src_i}_rgb"
        local txt_rgb_var="dcol_txt${src_i}_rgb"
        if [[ -n ${!pry_rgba_var:-} && -z ${!pry_rgb_var:-} ]]; then
            declare -g "$pry_rgb_var=$(sed -E 's/rgba\(([0-9]+,[0-9]+,[0-9]+),.*/\1/' <<< "${!pry_rgba_var}")"
            export "${pry_rgb_var?}"
        fi
        if [[ -n ${!txt_rgba_var:-} && -z ${!txt_rgb_var:-} ]]; then
            declare -g "$txt_rgb_var=$(sed -E 's/rgba\(([0-9]+,[0-9]+,[0-9]+),.*/\1/' <<< "${!txt_rgba_var}")"
            export "${txt_rgb_var?}"
        fi
        [ -n "${!pry_var:-}" ] && sed_script+="s|<wallbash_pry$i>|${!pry_var}|g;"
        [ -n "${!txt_var:-}" ] && sed_script+="s|<wallbash_txt$i>|${!txt_var}|g;"
        [ -n "${!pry_rgba_var:-}" ] && sed_script+="s|<wallbash_pry${i}_rgba(\([^)]*\))>|${!pry_rgba_var}|g;"
        [ -n "${!txt_rgba_var:-}" ] && sed_script+="s|<wallbash_txt${i}_rgba(\([^)]*\))>|${!txt_rgba_var}|g;"
        [ -n "${!pry_rgb_var:-}" ] && sed_script+="s|<wallbash_pry${i}_rgb>|${!pry_rgb_var}|g;"
        [ -n "${!txt_rgb_var:-}" ] && sed_script+="s|<wallbash_txt${i}_rgb>|${!txt_rgb_var}|g;"
        for j in {1..9}; do
            local xa_var="dcol_${src_i}xa$j"
            local xa_rgba_var="dcol_${src_i}xa${j}_rgba"
            local xa_rgb_var="dcol_${src_i}xa${j}_rgb"
            if [[ -n ${!xa_rgba_var:-} && -z ${!xa_rgb_var:-} ]]; then
                declare -g "$xa_rgb_var=$(sed -E 's/rgba\(([0-9]+,[0-9]+,[0-9]+),.*/\1/' <<< "${!xa_rgba_var}")"
                export "${xa_rgb_var?}"
            fi
            [ -n "${!xa_var:-}" ] && sed_script+="s|<wallbash_${i}xa$j>|${!xa_var}|g;"
            [ -n "${!xa_rgba_var:-}" ] && sed_script+="s|<wallbash_${i}xa${j}_rgba(\([^)]*\))>|${!xa_rgba_var}|g;"
            [ -n "${!xa_rgb_var:-}" ] && sed_script+="s|<wallbash_${i}xa${j}_rgb>|${!xa_rgb_var}|g;"
        done
    done
    sed_script+="s|<<HOME>>|$HOME|g"
    printf "%s" "$sed_script"
}
preprocess_substitutions() {
    NORMAL_SED_SCRIPT=$(create_wallbash_substitutions false)
    INVERTED_SED_SCRIPT=$(create_wallbash_substitutions true)
    export NORMAL_SED_SCRIPT INVERTED_SED_SCRIPT
}
kitty_theme_value() {
    local input_file="$1"
    local wanted_key="$2"
    [ -f "$input_file" ] || return 0
    awk -v wanted_key="$wanted_key" '$1 == wanted_key { print $2; exit }' "$input_file"
}
resolve_kitty_color() {
    local value="$1"
    local background="$2"
    local foreground="$3"
    local fallback="$4"

    case "${value,,}" in
    background) value="$background" ;;
    foreground) value="$foreground" ;;
    none | "") value="$fallback" ;;
    esac

    if [[ $value =~ ^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$ ]]; then
        printf '%s' "$value"
    else
        printf '%s' "$fallback"
    fi
}
color_brightness() {
    local hex="${1#\#}"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))

    printf '%s' $(((299 * r + 587 * g + 114 * b) / 1000))
}
readable_or() {
    local value="$1"
    local background="$2"
    local fallback="$3"
    local value_brightness background_brightness delta

    value_brightness=$(color_brightness "$value")
    background_brightness=$(color_brightness "$background")
    delta=$((value_brightness - background_brightness))
    [ "$delta" -lt 0 ] && delta=$((-delta))

    if [ "$delta" -ge 45 ]; then
        printf '%s' "$value"
    else
        printf '%s' "$fallback"
    fi
}
blend_colors() {
    local foreground="${1#\#}"
    local background="${2#\#}"
    local foreground_weight="$3"
    local background_weight=$((100 - foreground_weight))
    local fg_r=$((16#${foreground:0:2}))
    local fg_g=$((16#${foreground:2:2}))
    local fg_b=$((16#${foreground:4:2}))
    local bg_r=$((16#${background:0:2}))
    local bg_g=$((16#${background:2:2}))
    local bg_b=$((16#${background:4:2}))

    printf '#%02x%02x%02x' \
        $(((fg_r * foreground_weight + bg_r * background_weight) / 100)) \
        $(((fg_g * foreground_weight + bg_g * background_weight) / 100)) \
        $(((fg_b * foreground_weight + bg_b * background_weight) / 100))
}
abs() {
    local value="$1"
    [ "$value" -lt 0 ] && value=$((-value))
    printf '%s' "$value"
}
color_distance() {
    local left="${1#\#}"
    local right="${2#\#}"
    local left_r=$((16#${left:0:2}))
    local left_g=$((16#${left:2:2}))
    local left_b=$((16#${left:4:2}))
    local right_r=$((16#${right:0:2}))
    local right_g=$((16#${right:2:2}))
    local right_b=$((16#${right:4:2}))

    printf '%s' $(($(abs $((left_r - right_r))) + $(abs $((left_g - right_g))) + $(abs $((left_b - right_b)))))
}
wezterm_hover_accent() {
    local active="$1"
    local background="$2"
    local fallback="$3"
    shift 3
    local best=""
    local best_distance=9999
    local candidate distance contrast

    for candidate in "$@"; do
        distance=$(color_distance "$active" "$candidate")
        [ "$distance" -lt 80 ] && continue

        contrast=$(color_distance "$background" "$candidate")
        [ "$contrast" -lt 80 ] && continue

        if [ "$distance" -lt "$best_distance" ]; then
            best="$candidate"
            best_distance="$distance"
        fi
    done

    if [ -n "$best" ]; then
        printf '%s' "$best"
    else
        readable_or "$(blend_colors "$active" "$fallback" 65)" "$background" "$active"
    fi
}
wezterm_active_accent() {
    local candidate="$1"
    local background="$2"
    local foreground="$3"
    local red="$4"
    local white="$5"
    local bright_white="$6"

    case "${candidate,,}" in
    "${foreground,,}" | "${white,,}" | "${bright_white,,}")
        candidate="$red"
        ;;
    esac

    readable_or "$candidate" "$background" "$foreground"
}
generate_wezterm_lua_theme() {
    local terminal_file="$1"
    local overrides_file="$2"
    local output_file="$3"
    local bg fg cursor cursor_fg selection_fg selection_bg
    local active_tab_fg active_tab_bg inactive_tab_fg inactive_tab_bg hover_tab_fg tab_bar_bg
    local border active_status_fg inactive_status_fg tab_primary tab_primary_hover tab_active_fg tab_inactive_fg
    local tab_hover_fg tab_new_fg tab_new_hover_fg tab_bell tab_unseen tab_status
    local ansi brights ansi_defaults brights_defaults i

    mkdir -p "$(dirname "$output_file")"

    bg=$(resolve_kitty_color "$(kitty_theme_value "$terminal_file" background)" "#000000" "#ffffff" "#000000")
    fg=$(resolve_kitty_color "$(kitty_theme_value "$terminal_file" foreground)" "$bg" "#ffffff" "#ffffff")
    cursor=$(resolve_kitty_color "$(kitty_theme_value "$terminal_file" cursor)" "$bg" "$fg" "$fg")
    cursor_fg=$(resolve_kitty_color "$(kitty_theme_value "$terminal_file" cursor_text_color)" "$bg" "$fg" "$bg")
    selection_fg=$(resolve_kitty_color "$(kitty_theme_value "$terminal_file" selection_foreground)" "$bg" "$fg" "$bg")
    selection_bg=$(resolve_kitty_color "$(kitty_theme_value "$terminal_file" selection_background)" "$bg" "$fg" "$fg")

    ansi_defaults=("$bg" "#cc241d" "#98971a" "#d79921" "#458588" "#b16286" "#689d6a" "$fg")
    brights_defaults=("#928374" "#fb4934" "#b8bb26" "#fabd2f" "#83a598" "#d3869b" "#8ec07c" "$fg")
    ansi=()
    brights=()
    for i in {0..7}; do
        ansi+=("$(resolve_kitty_color "$(kitty_theme_value "$terminal_file" "color$i")" "$bg" "$fg" "${ansi_defaults[$i]}")")
        brights+=("$(resolve_kitty_color "$(kitty_theme_value "$terminal_file" "color$((i + 8))")" "$bg" "$fg" "${brights_defaults[$i]}")")
    done

    active_tab_fg=$(wezterm_active_accent \
        "$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" tab_primary)" "$bg" "$fg" "$fg")" \
        "$bg" \
        "$fg" \
        "${ansi[1]}" \
        "${ansi[7]}" \
        "${brights[7]}")
    active_tab_bg=$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" tab_active_bg)" "$bg" "$fg" "$bg")
    inactive_tab_fg=$(readable_or "$(blend_colors "$active_tab_fg" "$bg" 55)" "$bg" "$fg")
    inactive_tab_bg=$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" tab_inactive_bg)" "$bg" "$fg" "$bg")
    hover_tab_fg=$(wezterm_hover_accent \
        "$active_tab_fg" \
        "$bg" \
        "$fg" \
        "${ansi[3]}" \
        "${brights[3]}" \
        "${ansi[4]}" \
        "${ansi[6]}" \
        "${ansi[5]}" \
        "${ansi[2]}" \
        "${ansi[1]}" \
        "${brights[4]}" \
        "${brights[6]}" \
        "${brights[5]}" \
        "${brights[2]}" \
        "${brights[1]}")
    tab_bar_bg=$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" tab_hover_bg)" "$bg" "$fg" "$bg")

    border=$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" border)" "$bg" "$fg" "$active_tab_fg")
    active_status_fg=$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" active_status_fg)" "$bg" "$fg" "$active_tab_fg")
    inactive_status_fg=$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" inactive_status_fg)" "$bg" "$fg" "$inactive_tab_fg")
    tab_primary=$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" tab_primary)" "$bg" "$fg" "$active_tab_fg")
    tab_primary_hover=$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" tab_primary_hover)" "$bg" "$fg" "$hover_tab_fg")
    tab_active_fg=$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" tab_active_fg)" "$bg" "$fg" "$active_tab_fg")
    tab_inactive_fg=$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" tab_inactive_fg)" "$bg" "$fg" "$inactive_tab_fg")
    tab_hover_fg=$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" tab_hover_fg)" "$bg" "$fg" "$hover_tab_fg")
    tab_new_fg=$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" tab_new_fg)" "$bg" "$fg" "$fg")
    tab_new_hover_fg=$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" tab_new_hover_fg)" "$bg" "$fg" "$hover_tab_fg")
    tab_bell=$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" tab_bell)" "$bg" "$fg" "${brights[3]}")
    tab_unseen=$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" tab_unseen)" "$bg" "$fg" "$inactive_tab_fg")
    tab_status=$(resolve_kitty_color "$(kitty_theme_value "$overrides_file" tab_status)" "$bg" "$fg" "$active_tab_fg")

    {
        printf '%s\n' '-- Generated by color.set.sh // Read-only'
        printf '%s\n' 'return {'
        printf '%s\n' '    scheme_name = "HyDE",'
        printf '%s\n' '    scheme = {'
        printf '        foreground = "%s",\n' "$fg"
        printf '        background = "%s",\n' "$bg"
        printf '        cursor_bg = "%s",\n' "$cursor"
        printf '        cursor_border = "%s",\n' "$cursor"
        printf '        cursor_fg = "%s",\n' "$cursor_fg"
        printf '        selection_fg = "%s",\n' "$selection_fg"
        printf '        selection_bg = "%s",\n' "$selection_bg"
        printf '%s\n' '        ansi = {'
        for color in "${ansi[@]}"; do printf '            "%s",\n' "$color"; done
        printf '%s\n' '        },'
        printf '%s\n' '        brights = {'
        for color in "${brights[@]}"; do printf '            "%s",\n' "$color"; done
        printf '%s\n' '        },'
        printf '%s\n' '    },'
        printf '%s\n' '    colors = {'
        printf '        fg = "%s",\n' "$fg"
        printf '        bg = "%s",\n' "$bg"
        printf '        comment = "%s",\n' "${brights[0]}"
        printf '        red = "%s",\n' "${ansi[1]}"
        printf '        green = "%s",\n' "${ansi[2]}"
        printf '        yellow = "%s",\n' "${ansi[3]}"
        printf '        blue = "%s",\n' "${ansi[4]}"
        printf '        magenta = "%s",\n' "${ansi[5]}"
        printf '        cyan = "%s",\n' "${ansi[6]}"
        printf '        selection = "%s",\n' "$selection_bg"
        printf '        caret = "%s",\n' "$cursor"
        printf '        border = "%s",\n' "$border"
        printf '        active_status = { bg_color = "none", fg_color = "%s" },\n' "$active_status_fg"
        printf '        inactive_status = { bg_color = "none", fg_color = "%s" },\n' "$inactive_status_fg"
        printf '%s\n' '        tab = {'
        printf '            primary = "%s",\n' "$tab_primary"
        printf '            primary_hover = "%s",\n' "$tab_primary_hover"
        printf '            active = { bg = "%s", fg = "%s" },\n' "$active_tab_bg" "$tab_active_fg"
        printf '            inactive = { bg = "%s", fg = "%s" },\n' "$inactive_tab_bg" "$tab_inactive_fg"
        printf '            hover = { bg = "%s", fg = "%s" },\n' "$tab_bar_bg" "$tab_hover_fg"
        printf '            new = { bg = "none", fg = "%s" },\n' "$tab_new_fg"
        printf '            new_hover = { bg = "none", fg = "%s" },\n' "$tab_new_hover_fg"
        printf '            bell = "%s",\n' "$tab_bell"
        printf '            unseen = "%s",\n' "$tab_unseen"
        printf '            status = "%s",\n' "$tab_status"
        printf '%s\n' '        },'
        printf '%s\n' '    },'
        printf '%s\n' '}'
    } > "$output_file"
}
generate_kitty_theme() {
    local terminal_file="$1"
    local overrides_file="$2"
    local output_file="$3"

    mkdir -p "$(dirname "$output_file")"
    {
        [ -f "$terminal_file" ] && sed '/^#/d; /^$/d' "$terminal_file" | sed "$NORMAL_SED_SCRIPT"
        [ -s "$overrides_file" ] && {
            printf '\n'
            sed '/^#/d; /^$/d' "$overrides_file"
        }
    } > "$output_file"
}
wallbash_deploy_target() {
    case "${1##*/}" in
    kitty.theme | kitty.dcol)
        printf '%s|%s\n' \
            '${KITTY_GENERATED_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/kitty}/theme.conf' \
            'killall -SIGUSR1 kitty'
        ;;
    waybar.theme | waybar.dcol)
        printf '%s|%s\n' \
            '${WAYBAR_GENERATED_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/waybar}/theme.css' \
            'hyde-shell waybar --update'
        ;;
    rofi.theme | rofi.dcol)
        printf '%s|%s\n' \
            '${ROFI_GENERATED_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/rofi}/theme.rasi' \
            ''
        ;;
    kvconfig.theme | kvconfig.dcol)
        printf '%s|%s\n' \
            '${KVANTUM_GENERATED_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/Kvantum/wallbash}/wallbash.kvconfig' \
            ''
        ;;
    kvantum.theme | kvantum.dcol)
        printf '%s|%s\n' \
            '${KVANTUM_GENERATED_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/Kvantum/wallbash}/wallbash.svg' \
            ''
        ;;
    wezterm.theme | wezterm.dcol)
        printf '%s|%s\n' \
            '${WEZTERM_GENERATED_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/wezterm}/theme.lua' \
            ''
        ;;
    esac
}
fn_wallbash() {
    local temp_target_file exec_command target_file template wallbash_dirs_array header has_deploy_header has_deploy_target
    template="$1"
    shift
    case "${template##*/}" in
    terminal.theme)
        return 0
        ;;
    esac
    has_deploy_header=0
    has_deploy_target=0
    wallbash_dirs_array=("$@")
    WALLBASH_SCRIPTS="${template%%/wallbash/*}/wallbash/scripts"
    if [[ -n $(wallbash_deploy_target "$template") ]]; then
        eval target_file="$(wallbash_deploy_target "$template" | awk -F '|' '{print $1}')"
        exec_command="$(wallbash_deploy_target "$template" | awk -F '|' '{print $2}')"
        has_deploy_target=1
        header="$(head -1 "$template")"
        grep -q '|' <<< "$header" && has_deploy_header=1
    elif [[ $template == *.theme ]]; then
        local dcolTemplate template_name
        template_name="${template##*/}"
        template_name="${template_name%.*}"
        dcolTemplate=$(find -H "${wallbash_dirs_array[@]}" -type f -path "*/theme*" -name "$template_name.dcol" 2> /dev/null | awk '!seen[substr($0, match($0, /[^/]+$/))]++')
        if [[ -n $dcolTemplate ]]; then
            eval target_file="$(head -1 "$dcolTemplate" | awk -F '|' '{print $1}')"
            exec_command="$(head -1 "$dcolTemplate" | awk -F '|' '{print $2}')"
            has_deploy_target=1
            WALLBASH_SCRIPTS="${dcolTemplate%%/wallbash/*}/wallbash/scripts"
        fi
    fi
    if [[ $LOG_LEVEL == "debug" ]]; then
        print_log -sec "wallbash" -stat "Template:" " $template"
        print_log -sec "wallbash" -stat "Wallbash Directories:" " ${wallbash_dirs_array[*]}"
        print_log -sec "wallbash" -stat "Wallbash Scripts:" " $WALLBASH_SCRIPTS"
    fi
    [ -f "${XDG_STATE_HOME:-$HOME/.local/state}/hypr/hyde.conf" ] && source "${XDG_STATE_HOME:-$HOME/.local/state}/hypr/hyde.conf"
    [ -f "${WAYBAR_STATE_FILE:-${XDG_STATE_HOME:-$HOME/.local/state}/waybar/state}" ] && source "${WAYBAR_STATE_FILE:-${XDG_STATE_HOME:-$HOME/.local/state}/waybar/state}"
    if [[ -n ${WALLBASH_SKIP_TEMPLATE[*]} ]]; then
        for skip in "${WALLBASH_SKIP_TEMPLATE[@]}"; do
            if [[ $template =~ $skip ]]; then
                print_log -sec "wallbash" -warn "skip '$skip' template " "Template: $template"
                return 0
            fi
        done
    fi
    header="$(head -1 "$template")"
    grep -q '|' <<< "$header" && has_deploy_header=1
    [ -z "$target_file" ] && eval target_file="$(awk -F '|' '{print $1}' <<< "$header")"
    if [ -z "$target_file" ] || [[ $has_deploy_header -ne 1 && $has_deploy_target -ne 1 ]]; then
        print_log -sec "wallbash" -warn "skip 'no deploy header'" "$template"
        return 0
    fi
    if [[ -n $(wallbash_deploy_target "$template") ]]; then
        mkdir -p "$(dirname "$target_file")"
    elif [ ! -d "$(dirname "$target_file")" ]; then
        print_log -sec "wallbash" -warn "skip 'missing directory'" "$target_file // Do you have the dependency installed?"
        return 0
    fi
    export wallbashScripts="$WALLBASH_SCRIPTS"
    export WALLBASH_SCRIPTS confDir hydeConfDir cacheDir thmbDir dcolDir iconsDir themesDir fontsDir wallbashDirs PALETTE_SOURCE HYDE_THEME_DIR HYDE_THEME GTK_ICON GTK_THEME CURSOR_THEME
    export -f pkg_installed print_log
    exec_command="${exec_command:-"$(head -1 "$template" | awk -F '|' '{print $2}')"}"
    temp_target_file="$(mktemp)"
    if [[ $has_deploy_header -eq 1 ]]; then
        sed '1d' "$template" > "$temp_target_file"
    else
        cp "$template" "$temp_target_file"
    fi
    if [[ ${revert_colors:-0} -eq 1 ]] || [[ ${PALETTE_SOURCE:-theme} == "wallbash_dark" && ${dcol_mode:-} == "light" ]] || [[ ${PALETTE_SOURCE:-theme} == "wallbash_light" && ${dcol_mode:-} == "dark" ]]; then
        sed -i "$INVERTED_SED_SCRIPT" "$temp_target_file"
    else
        sed -i "$NORMAL_SED_SCRIPT" "$temp_target_file"
    fi
    case "${template##*/}" in
    kitty.theme | kitty.dcol)
        generate_kitty_theme \
            "$(dirname "$template")/terminal.theme" \
            "$temp_target_file" \
            "$target_file"
        rm -f "$temp_target_file"
        ;;
    wezterm.theme)
        generate_wezterm_lua_theme \
            "$(dirname "$template")/terminal.theme" \
            "$temp_target_file" \
            "${WEZTERM_GENERATED_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/wezterm}/theme.lua"
        rm -f "$temp_target_file"
        ;;
    wezterm.dcol)
        mkdir -p "${WEZTERM_GENERATED_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/wezterm}"
        if [ -s "$temp_target_file" ]; then
            mv "$temp_target_file" "${WEZTERM_GENERATED_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/wezterm}/theme.lua"
        fi
        ;;
    *)
        if [ -s "$temp_target_file" ]; then
            mv "$temp_target_file" "$target_file"
        fi
        ;;
    esac
    [ -z "$exec_command" ] || {
        [[ $LOG_LEVEL == "debug" ]] && print_log -sec "wallbash" -stat "Exec command:" " $exec_command from $WALLBASH_SCRIPTS"
        bash -c "$exec_command" &
        disown
    }
}
scrDir="$(dirname "$(realpath "$0")")"
export scrDir
source "$scrDir/globalcontrol.sh"
confDir="${XDG_CONFIG_HOME:-$(xdg-user-dir CONFIG)}"
wallbash_image="$1"
dcol_colors=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dcol)
            dcol_colors="$2"
            if [ -f "$dcol_colors" ]; then
                printf "[Source] %s\n" "$dcol_colors"
                source "$dcol_colors"
                shift 2
            else
                dcol_colors="$(find -H "$dcolDir" -type f -name "*.dcol" | shuf -n 1)"
                printf "[Dcol Colors] %s\n" "$dcol_colors"
                shift
            fi
            ;;
        --wall)
            wallbash_image="$2"
            shift 2
            ;;
        --single)
            [ -f "$wallbash_image" ] || wallbash_image="${HYPR_STATE_HOME:-${XDG_STATE_HOME:-$HOME/.local/state}/hypr}/wallpaper"
            single_template="$2"
            printf "[wallbash] Single template: %s\n" "$single_template"
            printf "[wallbash] Wallpaper: %s\n" "$wallbash_image"
            shift 2
            ;;
        -*)
            printf "Usage: %s [--dcol <mode>] [--wall <image>] [--single] [--mode <mode>] [--help]\n" "$0"
            exit 0
            ;;
        *) break ;;
    esac
done
if [ -z "$wallbash_image" ] || [ ! -f "$wallbash_image" ]; then
    printf "Error: Input wallpaper not found!\n"
    exit 1
fi
dcol_file="$dcolDir/$(set_hash "$wallbash_image").dcol"
if [ ! -f "$dcol_file" ]; then
    "$scrDir/wallpaper/cache.sh" commence -w "$wallbash_image" &> /dev/null
fi
set -a
source "$dcol_file"
if [ -f "$HYDE_THEME_DIR/theme.dcol" ] && [ "$PALETTE_SOURCE" = "theme" ]; then
    source "$HYDE_THEME_DIR/theme.dcol"
    print_log -sec "wallbash" -stat "override" "dominant colors from $HYDE_THEME theme"
    print_log -sec "wallbash" -stat " NOTE" "Remove \"$HYDE_THEME_DIR/theme.dcol\" to use wallpaper dominant colors"
fi
[ "$dcol_mode" == "dark" ] && dcol_invt="light" || dcol_invt="dark"
set +a
preprocess_substitutions
echo "[DEBUG color.set.sh] AFTER_PREPROCESS" >> /tmp/color_set_debug.log 2>&1
print_log -sec "wallbash" -stat "preprocessed" "color substitutions"
revert_colors=0
[ "$PALETTE_SOURCE" = "theme" ] && {
    grep -q "$dcol_mode" <<< "$(get_hyprConf "COLOR_SCHEME")" || revert_colors=1
}
export revert_colors
load_dconf_kdeglobals
export GTK_THEME GTK_ICON CURSOR_THEME COLOR_SCHEME
WALLBASH_DIRS=""
for dir in "${wallbashDirs[@]}"; do
    [ -d "$dir" ] || wallbashDirs=("${wallbashDirs[@]//$dir/}")
    [ -d "$dir" ] && WALLBASH_DIRS+="$dir:"
done
WALLBASH_DIRS="${WALLBASH_DIRS%:}"
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then PATH="$HOME/.local/bin:$PATH"; fi
export WALLBASH_DIRS PATH
export -f fn_wallbash print_log pkg_installed create_wallbash_substitutions preprocess_substitutions
export -f generate_wezterm_lua_theme generate_kitty_theme kitty_theme_value resolve_kitty_color
export -f color_brightness readable_or blend_colors abs color_distance wezterm_hover_accent wezterm_active_accent
export -f wallbash_deploy_target
if [ -n "$dcol_colors" ]; then
    set -a
    source "$dcol_colors"
    print_log -sec "wallbash" -stat "single instance" "Wallbash Colors: $dcol_colors"
    set +a
fi
if [ -n "$single_template" ]; then
    fn_wallbash "$single_template" "${wallbashDirs[@]}"
    exit 0
fi
[ -t 1 ] && "$scrDir/wallbash.print.colors.sh"
print_log -sec "wallbash" -stat "wallbash directories" " $WALLBASH_DIRS"
if [ "$PALETTE_SOURCE" = "theme" ] && [[ $reload_flag -eq 1 ]]; then
    print_log -sec "wallbash" -stat "apply $dcol_mode colors" "$HYDE_THEME theme"
    mapfile -d '' -t deployList < <(find -H "$HYDE_THEME_DIR" -type f -name "*.theme" -print0)
    while read -r pKey; do
        fKey="$(find -H "$HYDE_THEME_DIR" -type f -name "$(basename "${pKey%.dcol}.theme")")"
        [ -z "$fKey" ] && deployList+=("$pKey")
    done < <(find -H "${wallbashDirs[@]}" -type f -path "*/theme*" -name "*.dcol" 2> /dev/null | awk '!seen[substr($0, match($0, /[^/]+$/))]++')
    parallel fn_wallbash {} "${wallbashDirs[@]}" ::: "${deployList[@]}" || true
    find -H "${wallbashDirs[@]}" -type f -path "*/always*" -name "*.dcol" 2> /dev/null | awk '!seen[substr($0, match($0, /[^/]+$/))]++' | parallel fn_wallbash {} "${wallbashDirs[@]}" || true
elif [ "$PALETTE_SOURCE" != "theme" ]; then
    print_log -sec "wallbash" -stat "apply $dcol_mode colors" "Wallbash theme"
    find -H "${wallbashDirs[@]}" -type f -path "*/theme*" -name "*.dcol" 2> /dev/null | awk '!seen[substr($0, match($0, /[^/]+$/))]++' | parallel fn_wallbash {} "${wallbashDirs[@]}" || true
fi
if [ "$PALETTE_SOURCE" != "theme" ]; then
    find -H "${wallbashDirs[@]}" -type f -path "*/always*" -name "*.dcol" 2> /dev/null | awk '!seen[substr($0, match($0, /[^/]+$/))]++' | parallel fn_wallbash {} "${wallbashDirs[@]}" || true
fi
