local wezterm = require "wezterm"
local platform = require "scripts.platform"

local M = {}
local START_WITH_WALLPAPER = false

local function base_config(config)
  config.default_cursor_style = 'BlinkingBar'
  config.cursor_blink_rate = 2000
  config.window_decorations = platform.is_linux_wayland() and "NONE" or "RESIZE"
  config.initial_cols = 120
  config.initial_rows = 40
  config.window_padding = { left = 25, right = 25, top = 25, bottom = 25 }
  config.window_frame = {
    font_size = 15,
    active_titlebar_bg = "transparent",
    inactive_titlebar_bg = "transparent",
    active_titlebar_border_bottom = "transparent",
    inactive_titlebar_border_bottom = "transparent",
    button_bg = "transparent",
    button_hover_bg = "transparent",
    border_left_width = "0px",
    border_right_width = "10px",
    border_bottom_height = "10px",
    border_top_height = "1px",
    border_left_color = "transparent",
    border_right_color = "transparent",
    border_top_color = "transparent",
    border_bottom_color = "transparent",
  }
end

local function backdrop(config, colors)
  if platform.is_windows_11() then
    config.win32_system_backdrop = 'Acrylic'
  end

  -- Workaround: window_background_opacity does not apply to the tab bar.
  config.background = {
    {
      source = { Color = "#302e2e" },
      width = "100%",
      height = "100%",
      opacity = 0.88,
    },
  }

  -- Blur managed by Hyperland on Linux
end

function M.setup(config, colors)
  base_config(config)
  backdrop(config, colors)
end

function M.apply_base_background(window, colors)
  local appearance_config = {}
  M.setup(appearance_config, colors)

  local overrides = window:get_config_overrides() or {}
  overrides.background = appearance_config.background
  overrides.window_background_opacity = appearance_config.window_background_opacity
  overrides.win32_system_backdrop = appearance_config.win32_system_backdrop
  overrides.win32_acrylic_accent_color = nil
  window:set_config_overrides(overrides)
end

function M.should_start_with_wallpaper()
  return START_WITH_WALLPAPER
end

return M
