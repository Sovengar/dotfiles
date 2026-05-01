local wezterm = require "wezterm"

local M = {}

M.setup = function(config, colors)
  config.default_cursor_style = 'BlinkingUnderline'

  config.window_background_gradient = {
    orientation = "Vertical",
    interpolation = "Linear",
    blend = "Rgb",
    colors = {
      colors.bg,
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

  config.window_background_opacity = 0.96
end

return M
