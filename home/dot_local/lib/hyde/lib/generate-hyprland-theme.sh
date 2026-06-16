#!/usr/bin/env bash

hyde_theme_log_warn() {
    if declare -F print_log >/dev/null 2>&1; then
        print_log -sec "hypr-theme" -warn "$1" "${2:-}"
    else
        printf '[hypr-theme][warn] %s %s\n' "$1" "${2:-}" >&2
    fi
}

hypr_theme_value() {
    local input_file="$1"
    local wanted_key="$2"
    awk -v wanted_key="$wanted_key" '
        function trim(value) {
            sub(/^[[:space:]]+/, "", value)
            sub(/[[:space:]]+$/, "", value)
            return value
        }
        function normalize(value) {
            gsub(/:/, ".", value)
            return value
        }
        /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
        /\{[[:space:]]*$/ {
            line = $0
            sub(/\{[[:space:]]*$/, "", line)
            stack[++depth] = normalize(trim(line))
            next
        }
        /^[[:space:]]*}[[:space:]]*$/ {
            delete stack[depth--]
            next
        }
        /=/ {
            line = $0
            sub(/[[:space:]]+#.*$/, "", line)
            split(line, parts, "=")
            key = normalize(trim(parts[1]))
            value = trim(substr(line, index(line, "=") + 1))
            prefix = ""
            for (i = 1; i <= depth; i++) {
                prefix = prefix (prefix == "" ? "" : ".") stack[i]
            }
            full_key = prefix == "" ? key : prefix "." key
            if (full_key == wanted_key) {
                print value
                exit
            }
        }
    ' "$input_file"
}

lua_string() {
    local value="$1"
    if [ -z "$value" ]; then
        printf 'nil'
        return
    fi
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    printf '"%s"' "$value"
}

lua_number() {
    local value="$1"
    [[ $value =~ ^-?[0-9]+([.][0-9]+)?$ ]] && printf '%s' "$value" || printf 'nil'
}

lua_bool() {
    case "${1,,}" in
    yes | true | on | 1) printf 'true' ;;
    no | false | off | 0) printf 'false' ;;
    *) printf 'nil' ;;
    esac
}

lua_gradient() {
    local value="$1"
    local colors=()
    local remaining="$value"
    local color_pattern='rgba\([^)]*\)'
    while [[ $remaining =~ $color_pattern ]]; do
        colors+=("${BASH_REMATCH[0]}")
        remaining="${remaining#*${BASH_REMATCH[0]}}"
    done

    if [ ${#colors[@]} -eq 0 ]; then
        printf 'nil'
        return
    fi

    local angle
    angle="$(grep -oE -- '-?[0-9]+deg' <<<"$value" | grep -oE -- '-?[0-9]+' | tail -n 1)"

    printf '{ colors = {'
    local color
    for color in "${colors[@]}"; do
        printf ' '
        lua_string "$color"
        printf ','
    done
    printf ' }, angle = %s }' "${angle:-nil}"
}

theme_gradient_or_nil() {
    local input_file="$1"
    local key="$2"
    local value
    value="$(hypr_theme_value "$input_file" "$key")"
    if [ -z "$value" ]; then
        hyde_theme_log_warn "fallback" "missing '$key' in $input_file; writing nil"
    fi
    lua_gradient "$value"
}

color_conf_value() {
    local colors_file="$1"
    local wanted_key="$2"
    awk -v wanted_key="$wanted_key" '
        /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
        {
            line = $0
            sub(/[[:space:]]+#.*$/, "", line)
        }
        match(line, /^\$([A-Za-z0-9_]+)[[:space:]]*=[[:space:]]*([0-9A-Fa-f]+)/, m) {
            if (m[1] == wanted_key) {
                print toupper(m[2])
                exit
            }
        }
    ' "$colors_file"
}

rgba_token() {
    local colors_file="$1"
    local key="$2"
    local alpha="$3"
    local hex
    hex="$(color_conf_value "$colors_file" "$key")"
    [ -n "$hex" ] || return 1
    printf 'rgba(%s%s)' "$hex" "$alpha"
}

wallbash_gradient() {
    local input_file="$1"
    local colors_file="$2"
    local fallback_key="$3"
    local first_key="$4"
    local first_alpha="$5"
    local second_key="$6"
    local second_alpha="$7"
    local first second

    if [ ! -r "$colors_file" ]; then
        hyde_theme_log_warn "fallback" "colors file not readable: $colors_file; using theme '$fallback_key'"
        theme_gradient_or_nil "$input_file" "$fallback_key"
        return
    fi

    if ! first="$(rgba_token "$colors_file" "$first_key" "$first_alpha")"; then
        hyde_theme_log_warn "fallback" "missing '$first_key' in $colors_file; using theme '$fallback_key'"
        theme_gradient_or_nil "$input_file" "$fallback_key"
        return
    fi

    if ! second="$(rgba_token "$colors_file" "$second_key" "$second_alpha")"; then
        hyde_theme_log_warn "fallback" "missing '$second_key' in $colors_file; using theme '$fallback_key'"
        theme_gradient_or_nil "$input_file" "$fallback_key"
        return
    fi

    printf '{ colors = { '
    lua_string "$first"
    printf ', '
    lua_string "$second"
    printf ', }, angle = 45 }'
}

border_gradient() {
    local input_file="$1"
    local source="$2"
    local colors_file="$3"
    local key="$4"
    shift 4

    if [ "$source" = "wallbash" ]; then
        wallbash_gradient "$input_file" "$colors_file" "$key" "$@"
    else
        theme_gradient_or_nil "$input_file" "$key"
    fi
}

border_comment() {
    [ "$1" = "wallbash" ] && printf ' -- wallbash'
}

generate_hyprland_lua_theme() {
    local input_file="$1"
    local output_file="$2"
    shift 2

    local border_source="theme"
    local colors_file=""
    while [ $# -gt 0 ]; do
        case "$1" in
        --borders)
            border_source="$2"
            shift 2
            ;;
        --colors-file)
            colors_file="$2"
            shift 2
            ;;
        *)
            hyde_theme_log_warn "unknown-option" "$1"
            shift
            ;;
        esac
    done

    if [ "$border_source" = "wallbash" ] && [ -z "$colors_file" ]; then
        hyde_theme_log_warn "fallback" "--borders wallbash without --colors-file; using theme borders"
        border_source="theme"
    fi

    mkdir -p "$(dirname "$output_file")"
    {
        printf '%s\n' '-- Generated by HyDE // Read-only'
        printf '%s\n' '-- Manual edits are not visible until you run: hyprctl reload'
        printf '%s\n' 'return {'
        printf '%s\n' '    general = {'
        printf '        gaps_in = %s,\n' "$(lua_number "$(hypr_theme_value "$input_file" "general.gaps_in")")"
        printf '        gaps_out = %s,\n' "$(lua_number "$(hypr_theme_value "$input_file" "general.gaps_out")")"
        printf '        border_size = %s,\n' "$(lua_number "$(hypr_theme_value "$input_file" "general.border_size")")"
        printf '        layout = %s,\n' "$(lua_string "$(hypr_theme_value "$input_file" "general.layout")")"
        printf '        resize_on_border = %s,\n' "$(lua_bool "$(hypr_theme_value "$input_file" "general.resize_on_border")")"
        printf '        active_border = %s,%s\n' "$(border_gradient "$input_file" "$border_source" "$colors_file" "general.col.active_border" wallbash_pry4 ff wallbash_4xa1 ff)" "$(border_comment "$border_source")"
        printf '        inactive_border = %s,%s\n' "$(border_gradient "$input_file" "$border_source" "$colors_file" "general.col.inactive_border" wallbash_pry1 ff wallbash_pry2 ff)" "$(border_comment "$border_source")"
        printf '%s\n' '    },'
        printf '%s\n' '    group = {'
        printf '%s\n' '        col = {'
        printf '            border_active = %s,%s\n' "$(border_gradient "$input_file" "$border_source" "$colors_file" "group.col.border_active" wallbash_pry4 ff wallbash_4xa1 ff)" "$(border_comment "$border_source")"
        printf '            border_inactive = %s,%s\n' "$(border_gradient "$input_file" "$border_source" "$colors_file" "group.col.border_inactive" wallbash_pry1 cc wallbash_pry2 cc)" "$(border_comment "$border_source")"
        printf '            border_locked_active = %s,%s\n' "$(border_gradient "$input_file" "$border_source" "$colors_file" "group.col.border_locked_active" wallbash_txt3 ff wallbash_txt4 ff)" "$(border_comment "$border_source")"
        printf '            border_locked_inactive = %s,%s\n' "$(border_gradient "$input_file" "$border_source" "$colors_file" "group.col.border_locked_inactive" wallbash_txt1 cc wallbash_txt2 cc)" "$(border_comment "$border_source")"
        printf '%s\n' '        },'
        printf '%s\n' '    },'
        printf '%s\n' '    decoration = {'
        printf '        rounding = %s,\n' "$(lua_number "$(hypr_theme_value "$input_file" "decoration.rounding")")"
        printf '%s\n' '        shadow = {'
        printf '            enabled = %s,\n' "$(lua_bool "$(hypr_theme_value "$input_file" "decoration.shadow.enabled")")"
        printf '%s\n' '        },'
        printf '%s\n' '        blur = {'
        printf '            enabled = %s,\n' "$(lua_bool "$(hypr_theme_value "$input_file" "decoration.blur.enabled")")"
        printf '            size = %s,\n' "$(lua_number "$(hypr_theme_value "$input_file" "decoration.blur.size")")"
        printf '            passes = %s,\n' "$(lua_number "$(hypr_theme_value "$input_file" "decoration.blur.passes")")"
        printf '            contrast = %s,\n' "$(lua_number "$(hypr_theme_value "$input_file" "decoration.blur.contrast")")"
        printf '            noise = %s,\n' "$(lua_number "$(hypr_theme_value "$input_file" "decoration.blur.noise")")"
        printf '            new_optimizations = %s,\n' "$(lua_bool "$(hypr_theme_value "$input_file" "decoration.blur.new_optimizations")")"
        printf '            ignore_opacity = %s,\n' "$(lua_bool "$(hypr_theme_value "$input_file" "decoration.blur.ignore_opacity")")"
        printf '            xray = %s,\n' "$(lua_bool "$(hypr_theme_value "$input_file" "decoration.blur.xray")")"
        printf '%s\n' '        },'
        printf '%s\n' '    },'
        printf '%s\n' '}'
    } >"$output_file"
}

generate_waybar_theme() {
    local input_file="$1"
    local output_file="$2"
    mkdir -p "$(dirname "$output_file")"
    {
        printf '# Generated by theme.switch.sh // Read-only\n'
        printf 'rounding = %s\n' "$(hypr_theme_value "$input_file" "decoration.rounding")"
    } >"$output_file"
}
