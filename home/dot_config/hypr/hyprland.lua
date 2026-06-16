--? Read https://hydeproject.pages.dev/en/configuring/hyprland/ for the full documentation.

local function load(module)
    package.loaded[module] = nil
    return require(module)
end

local home = os.getenv("HOME") or ""
package.path = home .. "/.local/lib/?.lua;" .. home .. "/.local/lib/?/init.lua;" .. package.path

-- HyDE compatibility and owned baseline config
load("hyprland.variables")   -- HyDE variables table (scrPath, envList, unit, cursor, fonts, etc.)
load("hyprland.env")         -- hl.env(): Qt, Mozilla, Electron, XDG, PATH
load("hyprland.hardware.nvidia")  -- Nvidia env and cursor settings
load("hyprland.style.opacity") -- baseline opacity and dimming
load("hyprland.layout")      -- layout defaults: dwindle, master, snap
load("hyprland.hardware.input")   -- keyboard, mouse, touchpad
load("hyprland.misc")        -- misc compositor defaults
load("hyprland.hardware.gestures") -- touchpad gesture defaults
load("hyprland.startup")     -- hl.on("hyprland.start"): dbus, polkit, bar, wallpaper, clipboard, applets, idle
load("hypr.scripts.startup_vars_loader") -- theme vars from generated state (written by theme.switch.sh on theme change)

-- User personal configuration
load("hyprland.hardware.monitors") -- monitor setup
load("hyprland.style.theme")      -- theme config from generated state
load("hyprland.style.animations") -- animation config from HYPR_ANIMATION state
load("hyprland.style.shaders")    -- screen shader config from generated state
load("hyprland.windowrules")      -- window rules
load("hyprland.style.windowrules") -- style-specific window rules
load("hypr.selected_workflow_loader") -- HyDE workflow overrides from HYPR_WORKFLOW state
load("hyprland.keybindings")      -- keyboard shortcuts

hl.on("hyprland.start", function()
    hl.exec_cmd("pypr")
end)
