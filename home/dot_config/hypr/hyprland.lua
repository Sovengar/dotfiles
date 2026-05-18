--[[
$HYDE_HYPRLAND=set #! Do not remove - HyDE marker to prevent file overwrite

#* You can freely edit this file, but make sure to not remove the above line!
#* All Files Below are yours to modify!

#!    ░▒▒▒░░░▓▓        ___________
#!   ░░▒▒▒░░░░░▓▓     //___________/
#!  ░░▒▒▒░░░░░▓▓  _   _ _    _ _____
#!  ░░▒▒░░░░░▓▓▓▓▓▓ | | | |  | |  __/
#!   ░▒▒░░░░▓▓   ▓▓ | |_| | |_/ /| |___
#!    ░▒▒░░▓▓   ▓▓   \__  |____/ |____/
#!      ░▒▓▓   ▓▓  //____/

# ------------------------------------------------------
#TODO Please remove this block if you are sure $HYPRLAND_CONFIG is set
#? This is only use for fallback
# Fallback when HYPRLAND_CONFIG is not set
# -------------------------------------------------------

#? Read https://hydeproject.pages.dev/en/configuring/hyprland/ for the full documentation.
]]

local function load(module)
    package.loaded[module] = nil
    return require(module)
end

-- HyDE infrastructure (migrated from ~/.local/share/hypr/*.conf)
load("hyprland.hyde.variables")   -- HyDE variables table (scrPath, envList, unit, cursor, fonts, etc.)
load("hyprland.hyde.env")         -- hl.env(): Qt, Mozilla, Electron, XDG, PATH
load("hyprland.hyde.nvidia")      -- hl.env()/cursor: controlled parse of nvidia.conf
load("hyprland.hyde.defaults")    -- hl.config(): opacity, blur, misc, gestures
load("hyprland.hyde.windowrules") -- hl.window_rule(): portal dialogs, floating, PiP, layer rules
load("hyprland.hyde.dynamic")     -- screen shader, font family, mkdir, keybinds hint
load("hyprland.hyde.startup")     -- hl.on("hyprland.start"): dbus, polkit, bar, wallpaper, clipboard, applets, idle
load("hyprland.hyde.wallbash")    -- wallbash metadata from themes/wallbash.conf

-- User personal configuration
load("hyprland.hypr_vars")        -- keybinding variables
load("hyprland.monitors")         -- monitor setup
load("hyprland.userprefs")        -- keyboard layout, touchpad, autostart
load("hyprland.hyde_theme")       -- wallbash: theme.conf / colors.conf parsing
load("hyprland.animations")       -- animation curves from animations.conf
load("hyprland.hyde.shaders")     -- screen shader from shaders.conf
load("hyprland.workflows")        -- workflow rules from workflows.conf
load("hyprland.windowrules")      -- user window rule overrides
load("hyprland.keybindings")      -- keyboard shortcuts

load("hyprland.hyde.finale")      -- HyDE metadata env/table for tooling

hl.on("hyprland.start", function()
    hl.exec_cmd("pypr")
end)
