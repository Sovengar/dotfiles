local state = require("hypr.scripts.generated_paths")

local defaults = {
    HYDE_THEME = "default",
    PALETTE_SOURCE = "theme",
    GTK_THEME = "default",
    COLOR_SCHEME = "prefer-dark",
    ICON_THEME = "default",
    CURSOR_THEME = "default",
    CURSOR_SIZE = 24,
    FONT = "Cantarell",
    FONT_SIZE = 10,
    DOCUMENT_FONT = "Cantarell",
    DOCUMENT_FONT_SIZE = 10,
    MONOSPACE_FONT = "CaskaydiaCove Nerd Font Mono",
    MONOSPACE_FONT_SIZE = 9,
    BAR_FONT = "JetBrainsMono Nerd Font",
    MENU_FONT = "Cantarell",
    NOTIFICATION_FONT = "Mononoki Nerd Font Mono",
    CODE_THEME = "Wallbash",
    SDDM_THEME = "Wallbash",
    TERMINAL = "wezterm",
}

local path = state.existing_generated("startup_vars.lua")
local file = io.open(path, "r")
if not file then
    return defaults
end

local content = file:read("*a")
file:close()

local ok, vars = pcall(dofile, path)
if ok and type(vars) == "table" then
    return vars
end

return defaults
