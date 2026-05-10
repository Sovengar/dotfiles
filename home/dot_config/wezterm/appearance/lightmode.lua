local wezterm = require "wezterm"

local M = {}

local modes = {
  dark = {
    scheme = "tokyonight_night",
    overlay = "#0f172a",
    highlight = "#a855f7",
  },
  light = {
    scheme = "tokyonight_day",
    overlay = "#cbd5e1",
    highlight = "#0284c7",
  },
}

function M.setup(global)
  global.light_mode = global.light_mode or false

  wezterm.on('toggle-light-mode', function(window, _)
    global.light_mode = not global.light_mode
    local mode = global.light_mode and modes.light or modes.dark

    local overrides = window:get_config_overrides() or {}
    overrides.color_scheme = mode.scheme
    overrides.colors = {
      cursor_bg = mode.highlight,
      cursor_border = mode.highlight,
    }

    if overrides.background and overrides.background[2] then
      overrides.background[2].source = { Color = mode.overlay }
    end

    window:set_config_overrides(overrides)
  end)
end

return M
