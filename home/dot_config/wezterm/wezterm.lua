local wezterm = require "wezterm"
local act = wezterm.action
local config = wezterm.config_builder()
local theme = require "appearance.theme"
local font = require "appearance.font"
local launchers = require "launchers"
local keys = require "keys"
local tabs = require "tabs"
local status = require "status"
local appearance = require "appearance"
local wallpaper = require "appearance.wallpaper"
local opacity = require "appearance.opacity"
local lightmode = require "appearance.lightmode"


-- Global state for dynamic features
local global = wezterm.GLOBAL

-- Launchers
launchers.setup(config)

-- Keybindings
keys.setup(config)

-- Set color schema
config.color_scheme = theme.scheme_name

config.color_schemes = {
  [theme.scheme_name] = theme.scheme,
}

-- Font configuration
font.setup(config)

-- Tabs configuration
tabs.setup(config, theme.colors)

-- Status configuration
config.status_update_interval = 2000
status.setup(theme.colors)

-- Appearance configuration
appearance.setup_wallpaper(config, theme.colors)

-- Dynamic modules
wallpaper.setup(config, global, theme.colors)
global.pre_toggle_opacity = config.window_background_opacity or 0.95
opacity.setup(global)
lightmode.setup(global)

-- Quick tab spawn
wezterm.on('new-ssh-tab', function(_, pane)
  local tab = pane:window():spawn_tab {}
  tab:set_title('ssh')
end)

wezterm.on('new-nu-tab', function(_, pane)
  local tab = pane:window():spawn_tab {}
  tab:set_title('alt')
end)

--[[
============================
Others
============================
]] --

config.enable_scroll_bar = false
config.warn_about_missing_glyphs = false
-- SSH
config.ssh_domains = {
  {
    name = 'jon',
    remote_address = "157.180.112.216",
    username = "buble",
    ssh_option = {
      identityfile = wezterm.home_dir .. '/.ssh/jon',
    }
  },
}
-- Performance settings
config.max_fps = 120
config.animation_fps = 120
config.prefer_egl = true

return config
