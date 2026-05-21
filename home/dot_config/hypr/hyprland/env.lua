local home = os.getenv("HOME") or ""
local config_home = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local vars = require("hyprland.variables")

local function env(key, value)
    hl.env(key, value)
end

local function env_if_unset(key, value)
    if os.getenv(key) == nil then
        hl.env(key, value)
    end
end

env_if_unset("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
env_if_unset("QT_QPA_PLATFORM", "wayland;xcb")
env_if_unset("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
env_if_unset("QT_QPA_PLATFORMTHEME", "qt6ct")

env_if_unset("MOZ_ENABLE_WAYLAND", "1")
env_if_unset("GDK_SCALE", "1")
env_if_unset("ELECTRON_OZONE_PLATFORM_HINT", "auto")

env_if_unset("XDG_CURRENT_DESKTOP", "Hyprland")
env_if_unset("XDG_SESSION_TYPE", "wayland")
env_if_unset("XDG_SESSION_DESKTOP", "Hyprland")
env_if_unset("HYPRLAND_CONFIG", config_home .. "/hypr/hyprland.lua")

env("PATH", home .. "/.local/bin:" .. vars.scrPath .. ":" .. (os.getenv("PATH") or ""))

env_if_unset("XDG_CONFIG_HOME", home .. "/.config")
env_if_unset("XDG_CACHE_HOME", home .. "/.cache")
env_if_unset("XDG_DATA_HOME", home .. "/.local/share")
env_if_unset("XDG_STATE_HOME", home .. "/.local/state")
