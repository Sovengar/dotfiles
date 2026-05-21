--? Read https://hydeproject.pages.dev/en/configuring/hyprland/ for the full documentation.

local function load(module)
    package.loaded[module] = nil
    return require(module)
end

-- HyDE compatibility and owned baseline config
load("hyprland.primary_apps") -- primary terminal, editor, file manager and browser
load("hyprland.variables")   -- HyDE variables table (scrPath, envList, unit, cursor, fonts, etc.)
load("hyprland.env")         -- hl.env(): Qt, Mozilla, Electron, XDG, PATH
load("hyprland.hardware.nvidia")  -- hl.env()/cursor: controlled parse of nvidia.conf
load("hyprland.opacity")     -- baseline opacity and dimming
load("hyprland.layout")      -- layout defaults: dwindle, master, snap
load("hyprland.hardware.input")   -- keyboard, mouse, touchpad
load("hyprland.misc")        -- misc compositor defaults
load("hyprland.xwayland")    -- XWayland compatibility defaults
load("hyprland.hardware.gestures") -- touchpad gesture defaults
load("hyprland.ecosystem")   -- Hyprland ecosystem flags
load("hyprland.dynamic")     -- screen shader, font family, mkdir, keybinds hint
load("hyprland.startup")     -- hl.on("hyprland.start"): dbus, polkit, bar, wallpaper, clipboard, applets, idle
load("hyprland.wallbash")    -- wallbash metadata from themes/wallbash.conf

-- User personal configuration
load("hyprland.hardware.monitors") -- monitor setup
load("hyprland.theme")            -- wallbash: theme.conf / colors.conf parsing
load("hyprland.animations")       -- animation curves from animations.conf
load("hyprland.shaders")          -- screen shader from shaders.conf
load("hyprland.workflows")        -- workflow rules from workflows.conf
load("hyprland.windowrules")      -- window and layer rules
load("hyprland.keybindings")      -- keyboard shortcuts

load("hyprland.finale")           -- HyDE metadata snapshot for tooling

hl.on("hyprland.start", function()
    hl.exec_cmd("pypr")
end)
