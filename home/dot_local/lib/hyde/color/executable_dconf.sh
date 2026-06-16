#!/usr/bin/env bash
[[ $HYDE_SHELL_INIT -ne 1 ]] && eval "$(hyde-shell init)"

DCONF_TRACE="${XDG_CACHE_HOME:-$HOME/.cache}/hyde/dconf.trace"
mkdir -p "$(dirname "$DCONF_TRACE")" 2>/dev/null || true
echo "=== dconf.sh $(date -Iseconds) ===" >> "$DCONF_TRACE"

# Step 1: defaults
source "${HYDE_DATA_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/hyde}/base_system_vars"
echo "step=defaults GTK_THEME=$GTK_THEME ICON_THEME=$ICON_THEME COLOR_SCHEME=$COLOR_SCHEME CURSOR_THEME=$CURSOR_THEME" >> "$DCONF_TRACE"

dconf_populate() {
    cat << EOF
[org/gnome/desktop/interface]
icon-theme='$ICON_THEME'
gtk-theme='$GTK_THEME'
color-scheme='$COLOR_SCHEME'
cursor-theme='$CURSOR_THEME'
cursor-size=$CURSOR_SIZE
font-name='$FONT $FONT_SIZE'
document-font-name='$DOCUMENT_FONT $DOCUMENT_FONT_SIZE'
monospace-font-name='$MONOSPACE_FONT $MONOSPACE_FONT_SIZE'
font-antialiasing='$FONT_ANTIALIASING'
font-hinting='$FONT_HINTING'

[org/gnome/desktop/default-applications/terminal]
exec='$(command -v "$TERMINAL")'

[org/gnome/desktop/wm/preferences]
button-layout='$BUTTON_LAYOUT'
EOF
}

# Step 2: determine hyq config
if [[ $HYPRLAND_CONFIG == *.lua ]]; then
    HYDE_HYQ_CONFIG="$HYDE_THEME_DIR/hypr.theme"
else
    HYDE_HYQ_CONFIG="$HYPRLAND_CONFIG"
fi
echo "step=hyq-config HYDE_HYQ_CONFIG=${HYDE_HYQ_CONFIG:-unset}" >> "$DCONF_TRACE"

# Step 3: hyq always — read theme values from hypr.theme
if [ -z "${GTK_THEME:-}" ] && [[ -r $HYDE_HYQ_CONFIG ]] && command -v "hyq" &> /dev/null; then
    print_log -sec "dconf" -warn "fallback" "theme vars not in env (standalone wallpaper change?); reading $HYDE_HYQ_CONFIG"
    echo "step=hyq-before GTK_THEME=$GTK_THEME ICON_THEME=$ICON_THEME COLOR_SCHEME=$COLOR_SCHEME" >> "$DCONF_TRACE"
    eval "$(
        hyq "$HYDE_HYQ_CONFIG" --source --export env \
            -Q '$GTK_THEME[string]' \
            -Q '$COLOR_SCHEME[string]' \
            -Q '$ICON_THEME[string]' \
            -Q '$CURSOR_THEME[string]' \
            -Q '$CURSOR_SIZE' \
            -Q '$BUTTON_LAYOUT[string]'
        for _hyq_var in FONT FONT_SIZE DOCUMENT_FONT DOCUMENT_FONT_SIZE MONOSPACE_FONT MONOSPACE_FONT_SIZE FONT_ANTIALIASING FONT_HINTING; do
            hyq "$HYDE_HYQ_CONFIG" --source --export env -Q "\$${_hyq_var}" 2>/dev/null
        done
    )"
    GTK_THEME=${__GTK_THEME:-$GTK_THEME}
    COLOR_SCHEME=${__COLOR_SCHEME:-$COLOR_SCHEME}
    ICON_THEME=${__ICON_THEME:-$ICON_THEME}
    CURSOR_THEME=${__CURSOR_THEME:-$CURSOR_THEME}
    CURSOR_SIZE=${__CURSOR_SIZE:-$CURSOR_SIZE}
    TERMINAL=${__TERMINAL:-$TERMINAL}
    FONT=${__FONT:-$FONT}
    FONT_SIZE=${__FONT_SIZE:-$FONT_SIZE}
    DOCUMENT_FONT=${__DOCUMENT_FONT:-$DOCUMENT_FONT}
    DOCUMENT_FONT_SIZE=${__DOCUMENT_FONT_SIZE:-$DOCUMENT_FONT_SIZE}
    MONOSPACE_FONT=${__MONOSPACE_FONT:-$MONOSPACE_FONT}
    MONOSPACE_FONT_SIZE=${__MONOSPACE_FONT_SIZE:-$MONOSPACE_FONT_SIZE}
    BUTTON_LAYOUT=${__BUTTON_LAYOUT:-$BUTTON_LAYOUT}
    FONT_ANTIALIASING=${__FONT_ANTIALIASING:-$FONT_ANTIALIASING}
    FONT_HINTING=${__FONT_HINTING:-$FONT_HINTING}
    echo "step=hyq-after GTK_THEME=$GTK_THEME ICON_THEME=$ICON_THEME COLOR_SCHEME=$COLOR_SCHEME __GTK_THEME=${__GTK_THEME:-unset}" >> "$DCONF_TRACE"
elif ! command -v "hyq" &>/dev/null; then
    print_log -sec "dconf" -warn "hyq" "hyq not available, skipping theme var query"
    echo "step=hyq-skip reason=hyq-not-found" >> "$DCONF_TRACE"
else
    print_log -sec "dconf" -warn "hyq" "config not readable: $HYDE_HYQ_CONFIG"
    echo "step=hyq-skip reason=config-not-readable config=$HYDE_HYQ_CONFIG" >> "$DCONF_TRACE"
fi

# Step 4: wallpaper mode override (dcol_mode from .dcol file)
COLOR_SCHEME="prefer-$dcol_mode"
echo "step=dcol-override COLOR_SCHEME=$COLOR_SCHEME dcol_mode=$dcol_mode" >> "$DCONF_TRACE"

# Step 5: wallbash GTK_THEME override
if [ "${PALETTE_SOURCE:-theme}" != "theme" ]; then
    GTK_THEME="Wallbash-Gtk"
    echo "step=wallbash-override GTK_THEME=$GTK_THEME PALETTE_SOURCE=$PALETTE_SOURCE" >> "$DCONF_TRACE"
else
    echo "step=wallbash-skip GTK_THEME=$GTK_THEME PALETTE_SOURCE=theme" >> "$DCONF_TRACE"
fi

# Step 6: revert_colors when theme conflicts with wallpaper mode
if [[ ${revert_colors:-0} -eq 1 ]] || [[ ${PALETTE_SOURCE:-theme} == "wallbash_dark" && ${dcol_mode:-} == "light" ]] || [[ ${PALETTE_SOURCE:-theme} == "wallbash_light" && ${dcol_mode:-} == "dark" ]]; then
    if [[ $dcol_mode == "dark" ]]; then
        COLOR_SCHEME="prefer-light"
    else
        COLOR_SCHEME="prefer-dark"
    fi
    echo "step=revert-colors COLOR_SCHEME=$COLOR_SCHEME revert_colors=${revert_colors:-0} dcol_mode=$dcol_mode PALETTE_SOURCE=${PALETTE_SOURCE:-theme}" >> "$DCONF_TRACE"
fi

echo "step=final GTK_THEME=$GTK_THEME ICON_THEME=$ICON_THEME COLOR_SCHEME=$COLOR_SCHEME CURSOR_THEME=$CURSOR_THEME FONT=$FONT FONT_SIZE=$FONT_SIZE" >> "$DCONF_TRACE"

DCONF_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/hyde/dconf"
{
    dconf load -f / < "$DCONF_FILE" && print_log -sec "dconf" -stat "preserve" "$DCONF_FILE"
    echo "step=dconf preserve=$DCONF_FILE" >> "$DCONF_TRACE"
} || {
    print_log -sec "dconf" -warn "failed to preserve" "$DCONF_FILE"
    echo "step=dconf preserve=failed file=$DCONF_FILE" >> "$DCONF_TRACE"
}
{
    dconf_populate > "$DCONF_FILE" && print_log -sec "dconf" -stat "populated" "$DCONF_FILE"
    echo "step=dconf populate=$DCONF_FILE" >> "$DCONF_TRACE"
} || {
    print_log -sec "dconf" -warn "failed to populate" "$DCONF_FILE"
    echo "step=dconf populate=failed file=$DCONF_FILE" >> "$DCONF_TRACE"
}
{
    dconf reset -f / < "$DCONF_FILE" && print_log -sec "dconf" -stat "reset" "$DCONF_FILE"
    echo "step=dconf reset=$DCONF_FILE" >> "$DCONF_TRACE"
} || {
    print_log -sec "dconf" -warn "failed to reset" "$DCONF_FILE"
    echo "step=dconf reset=failed file=$DCONF_FILE" >> "$DCONF_TRACE"
}
{
    dconf load -f / < "$DCONF_FILE" && print_log -sec "dconf" -stat "loaded" "$DCONF_FILE"
    echo "step=dconf loaded=$DCONF_FILE" >> "$DCONF_TRACE"
} || {
    print_log -sec "dconf" -warn "failed to load" "$DCONF_FILE"
    echo "step=dconf load=failed file=$DCONF_FILE" >> "$DCONF_TRACE"
}
print_log -sec "dconf" -stat "Loaded dconf settings"
print_log -y "#-----------------------------------------------#"
dconf_populate
print_log -y "#-----------------------------------------------#"
export GTK_THEME ICON_THEME COLOR_SCHEME CURSOR_THEME CURSOR_SIZE TERMINAL FONT FONT_SIZE DOCUMENT_FONT DOCUMENT_FONT_SIZE MONOSPACE_FONT MONOSPACE_FONT_SIZE BAR_FONT MENU_FONT NOTIFICATION_FONT BUTTON_LAYOUT
echo "step=export-vars done" >> "$DCONF_TRACE"
