local wezterm = require "wezterm"

local M = {}

M.setup = function(config, theme)
  config.default_cursor_style = 'BlinkingUnderline'

  config.window_background_gradient = {
    orientation = "Vertical",
    interpolation = "Linear",
    blend = "Rgb",
    colors = {
      theme.bg,
      "#161b22"
    },
  }

  config.window_decorations = "RESIZE"

  config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  }

  config.window_frame = {
    border_left_width = "10px",
    border_right_width = "10px",
    border_bottom_height = "10px",
    border_top_height = "1px",
    border_left_color = "transparent",
    border_right_color = "transparent",
    border_top_color = "transparent",
    border_bottom_color = "transparent",
  }

  -- Wallpaper de fondo (desactivado mientras se usa acrílico en Win11)
  --[[
  config.background = {
    {
      source = { File = { path = wezterm.config_dir .. '/wallpaper.jpg', speed = 0.0 } },
      opacity = 0.25,
      width = "100%",
      hsb = { brightness = 0.5, saturation = 0.8, hue = 1.0 },
    }
  }
  --]]

  if wezterm.target_triple:find("windows") then
    -- Acrylic: fondo translúcido con blur (solo Windows 11 22H2+)
    config.window_background_opacity = 0.85
    config.win32_system_backdrop = 'Acrylic'
  else
    config.window_background_opacity = 0.96
  end
end

return M