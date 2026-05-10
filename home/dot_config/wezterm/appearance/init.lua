local wezterm = require "wezterm"

local M = {}

local function base_config(config)
  config.default_cursor_style = 'BlinkingUnderline'
  config.window_decorations = "RESIZE"
  config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
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
end

local function backdrop(config, colors)
  config.background = { {
    source = { Color = colors.bg },
    width = "100%",
    height = "100%",
    opacity = 0.95,
  } }

  if wezterm.target_triple:find("windows") then
    local is_win11 = false
    if type(wezterm.os_release_info) == "function" then
      local info = wezterm.os_release_info()
      is_win11 = info and info.build_number and tonumber(info.build_number) >= 22000
    end
    if is_win11 then
      config.window_background_opacity = 0.85
      config.win32_system_backdrop = 'Acrylic'
    else
      config.window_background_opacity = 0.96
    end
  else
    config.window_background_opacity = 0.96
  end
end

function M.setup_gradient(config, colors)
  base_config(config)
  backdrop(config, colors)
end

function M.setup_wallpaper(config, colors)
  base_config(config)
  backdrop(config, colors)
end

M.setup = M.setup_gradient

return M
