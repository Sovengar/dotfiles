local wezterm = require "wezterm"

local M = {}
local STEP = 0.05

function M.setup(global)
  global.pre_toggle_opacity = global.pre_toggle_opacity or 0.95

  wezterm.on('opacity-inc', function(window, _)
    local overrides = window:get_config_overrides() or {}
    local current = overrides.window_background_opacity or 1.0
    overrides.window_background_opacity = math.min(current + STEP, 1.0)
    window:set_config_overrides(overrides)
  end)

  wezterm.on('opacity-dec', function(window, _)
    local overrides = window:get_config_overrides() or {}
    local current = overrides.window_background_opacity or 1.0
    overrides.window_background_opacity = math.max(current - STEP, 0.2)
    window:set_config_overrides(overrides)
  end)

  wezterm.on('toggle-transparency', function(window, _)
    local overrides = window:get_config_overrides() or {}
    local current = overrides.window_background_opacity or 1.0
    local is_transparent = current < 1.0

    if is_transparent then global.pre_toggle_opacity = current end
    overrides.window_background_opacity = is_transparent and 1.0 or (global.pre_toggle_opacity or 0.95)
    window:set_config_overrides(overrides)
  end)
end

return M
