local home = os.getenv("HOME") or ""
local session = os.getenv("XDG_SESSION_DESKTOP") or "Hyprland"

local vars = {
    scrPath = home .. "/.local/lib/hyde",
    override = "override",

    envList = "WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP XDG_CONFIG_HOME QT_QPA_PLATFORMTHEME TERMINAL EDITOR EXPLORER BROWSER",
    unit = "hyde-" .. session,

    GTK_THEME = "Wallbash-Gtk",
    ICON_THEME = "Tela-circle-dracula",
    COLOR_SCHEME = "prefer-dark",
    BUTTON_LAYOUT = "",

    CURSOR_THEME = "Bibata-Modern-Ice",
    CURSOR_SIZE = 24,

    FONT = "Cantarell",
    FONT_SIZE = 11,
    DOCUMENT_FONT = "Cantarell",
    DOCUMENT_FONT_SIZE = 10,
    MONOSPACE_FONT = "CaskaydiaCove Nerd Font Mono",
    MONOSPACE_FONT_SIZE = 9,
    NOTIFICATION_FONT = "Mononoki Nerd Font Mono",
    BAR_FONT = "JetBrainsMono Nerd Font",
    MENU_FONT = "JetBrainsMono Nerd Font",
    FONT_ANTIALIASING = "rgba",
    FONT_HINTING = "",

    CODE_THEME = "",
    SDDM_THEME = "",

    TERMINAL = "wezterm",
    EDITOR = "code-oss",
    EXPLORER = "dolphin",
    BROWSER = "zen-browser",
}

return vars
