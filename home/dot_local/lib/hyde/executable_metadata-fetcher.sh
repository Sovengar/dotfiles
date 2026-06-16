#!/usr/bin/env bash
# metadata-fetcher.sh — query actual applied HyDE state from live sources
# Usage: hyde-shell metadata-fetcher [--env|--json|--check]
#
# Reads actual runtime state from gsettings, hyprctl, and generated configs.
# Falls back to env vars → base_system_vars defaults.
# --check compares applied vs desired (from hypr.theme) to detect drift.
# Output: KEY=VALUE (--env), JSON (--json), drift report (--check), or table (default).

[[ $HYDE_SHELL_INIT -ne 1 ]] && eval "$(hyde-shell init)"
source "${HYDE_DATA_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/hyde}/base_system_vars"

THEME_FILE=""
[ -n "${HYDE_THEME:-}" ] && THEME_FILE="${HYDE_THEME_DIR:-${HYDE_DATA_HOME:-$HOME/.local/share/hyde}/themes/$HYDE_THEME}/hypr.theme"

MODE="${1:-table}"

# ── Helpers ──────────────────────────────
gsetting() { gsettings get "$1" "$2" 2>/dev/null | tr -d "'"; }
hyprctl_int() { hyprctl getoption "$1" -j 2>/dev/null | jq -r '.int' 2>/dev/null; }

# Detect whether wallbash is actively overriding theme vars
WALLBASH_ACTIVE=false
if [[ ${PALETTE_SOURCE:-theme} != "theme" ]]; then
    WALLBASH_ACTIVE=true
fi

# True if wallbash mode AND the value matches a known wallbash override pattern
wallbash_overrides_var() {
    local val="$1"
    $WALLBASH_ACTIVE || return 1
    case "$val" in
        Wallbash-Gtk|Wallbash-*) return 0 ;;
        prefer-dark|prefer-light) return 0 ;;
        *) return 1 ;;
    esac
}

get_desired() {
    local var=$1
    if [ -r "$THEME_FILE" ] && command -v hyq &>/dev/null; then
        local line; line=$(hyq "$THEME_FILE" --source -Q "\$$var" 2>/dev/null)
        [ -n "$line" ] && { echo "$line"; return; }
    fi
    echo "${!var:-}"
}

# ── Getters: each prints VALUE|SOURCE ─────
gt_gtk_theme() {
    local v; v=$(gsetting org.gnome.desktop.interface gtk-theme)
    if [ -n "$v" ]; then
        wallbash_overrides_var "$v" && { echo "$v|wallbash"; return; }
        echo "$v|live"; return
    fi
    echo "${GTK_THEME:-Wallbash-Gtk}|env"
}

gt_color_scheme() {
    local v; v=$(gsetting org.gnome.desktop.interface color-scheme)
    if [ -n "$v" ]; then
        wallbash_overrides_var "$v" && { echo "$v|wallbash"; return; }
        echo "$v|live"; return
    fi
    echo "${COLOR_SCHEME:-prefer-dark}|env"
}

gt_icon_theme() {
    local v; v=$(gsetting org.gnome.desktop.interface icon-theme)
    [ -n "$v" ] && { echo "$v|live"; return; }
    echo "${ICON_THEME:-Tela-circle-dracula}|env"
}

gt_color_scheme() {
    local v; v=$(gsetting org.gnome.desktop.interface color-scheme)
    [ -n "$v" ] && { echo "$v|live"; return; }
    echo "${COLOR_SCHEME:-prefer-dark}|env"
}

gt_cursor_theme() {
    local v; v=$(gsetting org.gnome.desktop.interface cursor-theme)
    [ -n "$v" ] && { echo "$v|live"; return; }
    echo "${CURSOR_THEME:-Bibata-Modern-Ice}|env"
}

gt_cursor_size() {
    local v
    v=$(hyprctl_int cursor:size) && [ "$v" -gt 0 ] 2>/dev/null && { echo "$v|live"; return; }
    v=$(gsetting org.gnome.desktop.interface cursor-size)
    [ -n "$v" ] && { echo "$v|live"; return; }
    echo "${CURSOR_SIZE:-24}|env"
}

gt_font() {
    local v; v=$(gsetting org.gnome.desktop.interface font-name)
    if [ -n "$v" ]; then
        local name; name=$(awk '{$NF=""; sub(/ $/,""); print}' <<<"$v")
        [ -n "$name" ] && { echo "$name|live"; return; }
    fi
    echo "${FONT:-Cantarell}|env"
}

gt_font_size() {
    local v; v=$(gsetting org.gnome.desktop.interface font-name)
    if [ -n "$v" ]; then
        local size; size=$(awk '{print $NF}' <<<"$v")
        [ -n "$size" ] && [ "$size" -gt 0 ] 2>/dev/null && { echo "$size|derived"; return; }
    fi
    echo "${FONT_SIZE:-10}|env"
}

gt_bar_font() {
    local css="${WAYBAR_STATE_HOME:-${XDG_STATE_HOME:-$HOME/.local/state}/waybar}/includes/global.css"
    if [ -r "$css" ]; then
        local v; v=$(sed -n '/font-family/s/.*font-family:[[:space:]]*"//;s/".*//p' "$css" | head -1)
        [ -n "$v" ] && { echo "$v|config"; return; }
    fi
    echo "${BAR_FONT:-JetBrainsMono Nerd Font}|env"
}

gt_notification_font() {
    local dunst="${XDG_CONFIG_HOME:-$HOME/.config}/dunst/dunstrc"
    if [ -r "$dunst" ]; then
        local v; v=$(awk -F= '/^[[:space:]]*font[[:space:]]*=/{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$2); print $2; exit}' "$dunst")
        if [ -n "$v" ]; then
            if echo "$v" | grep -qE '\$\{|\$\(|_SIZE\b'; then
                echo "${NOTIFICATION_FONT:-Mononoki Nerd Font Mono}|env"
                return
            fi
            echo "$v|config"
            return
        fi
    fi
    echo "${NOTIFICATION_FONT:-Mononoki Nerd Font Mono}|env"
}

gt_menu_font() {
    echo "${MENU_FONT:-Cantarell}|env"
}

gt_document_font() {
    local v; v=$(gsetting org.gnome.desktop.interface document-font-name)
    if [ -n "$v" ]; then
        local name; name=$(awk '{$NF=""; sub(/ $/,""); print}' <<<"$v")
        [ -n "$name" ] && { echo "$name|live"; return; }
    fi
    echo "${DOCUMENT_FONT:-Cantarell}|env"
}

gt_monospace_font() {
    local v; v=$(gsetting org.gnome.desktop.interface monospace-font-name)
    if [ -n "$v" ]; then
        local name; name=$(awk '{$NF=""; sub(/ $/,""); print}' <<<"$v")
        [ -n "$name" ] && { echo "$name|live"; return; }
    fi
    echo "${MONOSPACE_FONT:-CaskaydiaCove Nerd Font Mono}|env"
}

gt_font_antialiasing() {
    local v; v=$(gsetting org.gnome.desktop.interface font-antialiasing)
    [ -n "$v" ] && { echo "$v|live"; return; }
    echo "${FONT_ANTIALIASING:-rgba}|env"
}

gt_font_hinting() {
    local v; v=$(gsetting org.gnome.desktop.interface font-hinting)
    [ -n "$v" ] && { echo "$v|live"; return; }
    echo "${FONT_HINTING:-}|env"
}

gt_button_layout() {
    local v; v=$(gsetting org.gnome.desktop.wm.preferences button-layout)
    [ -n "$v" ] && { echo "$v|live"; return; }
    echo "${BUTTON_LAYOUT:-}|env"
}

gt_terminal() {
    local v; v=$(gsetting org.gnome.desktop.default-applications.terminal exec 2>/dev/null)
    [ -n "$v" ] && { echo "$v|live"; return; }
    echo "${TERMINAL:-wezterm}|env"
}

gt_theme() { echo "${HYDE_THEME:-unknown}|env"; }
gt_palette_source() { echo "${PALETTE_SOURCE:-theme}|env"; }
gt_code_theme() { echo "${CODE_THEME:-Wallbash}|env"; }
gt_sddm_theme() { echo "${SDDM_THEME:-$CODE_THEME:-Wallbash}|env"; }
gt_lockscreen() { echo "hyprlock|hardcoded"; }

# ── Qt / Kvantum getters ─────────────────
gt_qt5_icon_theme() {
    local conf="${XDG_CONFIG_HOME:-$HOME/.config}/qt5ct/qt5ct.conf"
    if [ -r "$conf" ]; then
        local v; v=$(sed -n '/^\[Appearance\]/,/^\[/{s/^icon_theme=//p}' "$conf" | head -1)
        [ -n "$v" ] && { echo "$v|config"; return; }
    fi
    echo "${QT5_ICON_THEME:-${ICON_THEME:-Tela-circle-dracula}}|env"
}

gt_qt6_icon_theme() {
    local conf="${XDG_CONFIG_HOME:-$HOME/.config}/qt6ct/qt6ct.conf"
    if [ -r "$conf" ]; then
        local v; v=$(sed -n '/^\[Appearance\]/,/^\[/{s/^icon_theme=//p}' "$conf" | head -1)
        [ -n "$v" ] && { echo "$v|config"; return; }
    fi
    echo "${QT6_ICON_THEME:-${ICON_THEME:-Tela-circle-dracula}}|env"
}

gt_qt5_style() {
    local conf="${XDG_CONFIG_HOME:-$HOME/.config}/qt5ct/qt5ct.conf"
    if [ -r "$conf" ]; then
        local v; v=$(sed -n '/^\[Appearance\]/,/^\[/{s/^style=//p}' "$conf" | head -1)
        [ -n "$v" ] && { echo "$v|config"; return; }
    fi
    echo "${QT5_STYLE:-kvantum}|env"
}

gt_qt6_style() {
    local conf="${XDG_CONFIG_HOME:-$HOME/.config}/qt6ct/qt6ct.conf"
    if [ -r "$conf" ]; then
        local v; v=$(sed -n '/^\[Appearance\]/,/^\[/{s/^style=//p}' "$conf" | head -1)
        [ -n "$v" ] && { echo "$v|config"; return; }
    fi
    echo "${QT6_STYLE:-kvantum}|env"
}

gt_qt_platform_theme() {
    local v="${QT_QPA_PLATFORMTHEME:-}"
    [ -n "$v" ] && { echo "$v|env"; return; }
    echo "qt5ct|default"
}

gt_kvantum_theme() {
    local conf="${XDG_CONFIG_HOME:-$HOME/.config}/Kvantum/kvantum.kvconfig"
    if [ -r "$conf" ]; then
        local v; v=$(sed -n '/^\[General\]/,/^\[/{s/^theme=//p}' "$conf" | head -1)
        [ -n "$v" ] && { echo "$v|config"; return; }
    fi
    echo "${KVANTUM_THEME:-Wallbash}|env"
}

# ── Registry ─────────────────────────────
# kebab-name  env_name    getter  description  category
ENTRIES=(
    "theme:THEME:gt_theme:Theme name:Theme"
    "palette-source:PALETTE_SOURCE:gt_palette_source:Wallbash mode (theme/auto/dark/light):Theme"
    "code-theme:CODE_THEME:gt_code_theme:Code editor theme:Theme"
    "sddm-theme:SDDM_THEME:gt_sddm_theme:SDDM login theme:Theme"
    "gtk-theme:GTK_THEME:gt_gtk_theme:GTK theme:Desktop"
    "icon-theme:ICON_THEME:gt_icon_theme:Icon theme:Desktop"
    "color-scheme:COLOR_SCHEME:gt_color_scheme:Color scheme:Desktop"
    "cursor-theme:CURSOR_THEME:gt_cursor_theme:Cursor theme:Cursor"
    "cursor-size:CURSOR_SIZE:gt_cursor_size:Cursor size:Cursor"
    "font:FONT:gt_font:Interface font:Fonts"
    "font-size:FONT_SIZE:gt_font_size:Interface font size:Fonts"
    "bar-font:BAR_FONT:gt_bar_font:Bar font (Waybar):Fonts"
    "notification-font:NOTIFICATION_FONT:gt_notification_font:Notification font (Dunst):Fonts"
    "menu-font:MENU_FONT:gt_menu_font:Menu font (Rofi):Fonts"
    "document-font:DOCUMENT_FONT:gt_document_font:Document font:Fonts"
    "monospace-font:MONOSPACE_FONT:gt_monospace_font:Monospace font:Fonts"
    "font-antialiasing:FONT_ANTIALIASING:gt_font_antialiasing:Font antialiasing:Rendering"
    "font-hinting:FONT_HINTING:gt_font_hinting:Font hinting:Rendering"
    "button-layout:BUTTON_LAYOUT:gt_button_layout:Window button layout:System"
    "terminal:TERMINAL:gt_terminal:Default terminal:System"
    "lockscreen::gt_lockscreen:Lock screen:System"
    "qt5-icon-theme:QT5_ICON_THEME:gt_qt5_icon_theme:Qt5 icon theme:Qt"
    "qt6-icon-theme:QT6_ICON_THEME:gt_qt6_icon_theme:Qt6 icon theme:Qt"
    "qt5-style:QT5_STYLE:gt_qt5_style:Qt5 widget style:Qt"
    "qt6-style:QT6_STYLE:gt_qt6_style:Qt6 widget style:Qt"
    "qt-platform-theme:QT_QPA_PLATFORMTHEME:gt_qt_platform_theme:Qt platform theme:Qt"
    "kvantum-theme:KVANTUM_THEME:gt_kvantum_theme:Kvantum theme:Qt"
)

collect() {
    local IFS_save=$IFS
    IFS=':'
    local -a results=()
    local ok=0 total=0

    for entry in "${ENTRIES[@]}"; do
        set -- $entry
        local kebab=$1 env_name=$2 getter=$3 desc=$4 cat=$5
        IFS=$IFS_save

        local raw; raw=$($getter)
        local val src
        IFS='|' read -r val src <<<"$raw"

        APPLIED[$kebab]="$val"
        SOURCE[$kebab]="$src"
        CATEGORY[$kebab]="${cat:-}"

        if [ "$MODE" = "check" ]; then
            local desired=""
            if [ -n "$env_name" ]; then
                desired=$(get_desired "$env_name")
            fi
            DESIRED[$kebab]="$desired"
            if [ "$val" = "$desired" ] || { [ -z "$desired" ] && [ -z "$env_name" ]; }; then
                MATCH[$kebab]=1
                ((ok++))
            else
                MATCH[$kebab]=0
            fi
            ((total++))
        fi
        IFS=':'
    done
    IFS=$IFS_save
}

# ── Output formatters ────────────────────

fmt_env() {
    local IFS_save=$IFS
    IFS=':'
    for entry in "${ENTRIES[@]}"; do
        set -- $entry
        local kebab=$1 env_name=$2 getter=$3 desc=$4 cat=$5
        IFS=$IFS_save

        [ -z "$env_name" ] && { IFS=':'; continue; }

        local val=${APPLIED[$kebab]}
        local src=${SOURCE[$kebab]}
        printf '%-35s # source=%s\n' "${env_name}=${val}" "$src"
        IFS=':'
    done
    IFS=$IFS_save
}

fmt_json() {
    local first=1
    echo -n "{"
    local IFS_save=$IFS
    IFS=':'
    for entry in "${ENTRIES[@]}"; do
        set -- $entry
        local kebab=$1 env_name=$2 getter=$3 desc=$4 cat=$5
        IFS=$IFS_save

        [ "$first" -eq 1 ] && first=0 || echo -n ","
        local safe_key; safe_key=$(echo "$kebab" | tr '-' '_')
        local val=${APPLIED[$kebab]}
        local src=${SOURCE[$kebab]}
        local val_esc; val_esc=$(echo "$val" | sed 's/"/\\"/g')
        local cat_esc; cat_esc=$(echo "${cat:-}" | sed 's/"/\\"/g')
        printf '"%s":{"value":"%s","source":"%s","category":"%s"}' "$safe_key" "$val_esc" "$src" "$cat_esc"
        IFS=':'
    done
    IFS=$IFS_save
    echo "}"
}

fmt_human() {
    local maxlen=0
    local IFS_save=$IFS
    IFS=':'
    for entry in "${ENTRIES[@]}"; do
        set -- $entry
        local kebab=$1
        [ ${#kebab} -gt $maxlen ] && maxlen=${#kebab}
    done
    IFS=$IFS_save

    IFS=':'
    for entry in "${ENTRIES[@]}"; do
        set -- $entry
        local kebab=$1 env_name=$2 getter=$3 desc=$4 cat=$5
        IFS=$IFS_save

        local val=${APPLIED[$kebab]}
        local src=${SOURCE[$kebab]}
        printf "  %-*s  %-30s [%s]\n" "$maxlen" "$kebab" "$val" "$src"
        IFS=':'
    done
    IFS=$IFS_save
}

fmt_check() {
    local maxlen=0
    local IFS_save=$IFS
    IFS=':'
    for entry in "${ENTRIES[@]}"; do
        set -- $entry
        local kebab=$1
        [ ${#kebab} -gt $maxlen ] && maxlen=${#kebab}
    done
    IFS=$IFS_save

    local ok=0 total=0 overrides=0 issues=()
    IFS=':'
    for entry in "${ENTRIES[@]}"; do
        set -- $entry
        local kebab=$1 env_name=$2 getter=$3 desc=$4 cat=$5
        IFS=$IFS_save

        local val=${APPLIED[$kebab]}
        local src=${SOURCE[$kebab]}
        local desired_val=${DESIRED[$kebab]}
        local match=${MATCH[$kebab]:-1}

        ((total++))
        if [ "$src" = "wallbash" ]; then
            printf "  ○ %-*s  %-25s [wallbash] (theme: %s, override intencional)\n" "$maxlen" "$kebab" "$val" "$desired_val"
            ((overrides++))
            ((ok++))
        elif [ "$match" -eq 1 ]; then
            printf "  ✓ %-*s  %-25s [%s]\n" "$maxlen" "$kebab" "$val" "$src"
            ((ok++))
        else
            printf "  ✗ %-*s  %-25s [%s]  (theme: %s)\n" "$maxlen" "$kebab" "$val" "$src" "$desired_val"
            issues+=("$kebab: applied='$val' vs theme='$desired_val'")
        fi
        IFS=':'
    done
    IFS=$IFS_save

    echo ""
    if [ "$ok" -eq "$total" ]; then
        printf "  ✅ %d/%d variables coinciden con el theme" "$ok" "$total"
        [ "$overrides" -gt 0 ] && printf " (%d wallbash override(s) intencional)" "$overrides"
        printf "\n"
    else
        local drift=$((total - ok))
        printf "  ✅ %d/%d variables coinciden" "$ok" "$total"
        [ "$overrides" -gt 0 ] && printf " (%d wallbash override(s) intencional)" "$overrides"
        printf "\n"
        printf "  ⚠️  %d variables con drift:\n" "$drift"
        for issue in "${issues[@]}"; do
            printf "     • %s\n" "$issue"
        done
    fi
}

# ── Categorized table ─────────────────────
fmt_categorized() {
    local categories=("Theme" "Desktop" "Cursor" "Fonts" "Rendering" "System" "Qt")
    local kebab_max=0 val_max=0
    local IFS_save=$IFS
    IFS=':'
    for entry in "${ENTRIES[@]}"; do
        set -- $entry
        local kebab=$1 desc=$4
        IFS=$IFS_save
        [ ${#kebab} -gt $kebab_max ] && kebab_max=${#kebab}
        IFS=':'
    done
    IFS=$IFS_save

    for cat_name in "${categories[@]}"; do
        echo "  ── $cat_name ──"
        IFS=':'
        for entry in "${ENTRIES[@]}"; do
            set -- $entry
            local kebab=$1 env_name=$2 getter=$3 desc=$4 cat_e=$5
            IFS=$IFS_save
            if [ "${cat_e:-}" = "$cat_name" ]; then
                local val=${APPLIED[$kebab]}
                local src=${SOURCE[$kebab]}
                printf "    %-*s  %-30s [%s]\n" "$kebab_max" "$kebab" "$val" "$src"
            fi
            IFS=':'
        done
        IFS=$IFS_save
        echo ""
    done
}

# ── Waybar JSON output ────────────────────
fmt_waybar() {
    local tooltip
    tooltip=$(fmt_categorized)
    # Escape for JSON string (newlines, backslashes, quotes)
    local esc; esc=$(printf '%s' "$tooltip" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g')
    esc=$(printf '%s' "$esc" | awk '{printf "%s\\n", $0}')
    esc=$(echo "$esc" | sed 's/\\n$//')
    printf '{"text":" 󰋗 ","tooltip":"%s","class":""}' "$esc"
}

# ── Main ─────────────────────────────────
declare -a CATEGORY_ORDER=("Theme" "Desktop" "Cursor" "Fonts" "Rendering" "System")
declare -A APPLIED SOURCE DESIRED MATCH CATEGORY

collect

case "$MODE" in
    --env|-e) fmt_env ;;
    --json|-j) fmt_json ;;
    --check|-c) fmt_check ;;
    --categorized|-t) fmt_categorized ;;
    --waybar|-w) fmt_waybar ;;
    *) fmt_human ;;
esac
