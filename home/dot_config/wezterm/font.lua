local wezterm = require "wezterm"

local M = {}

M.font = wezterm.font_with_fallback({
  { family = 'JetBrainsMono Nerd Font', weight = 'Regular' },
  { family = 'JetBrainsMono Nerd Font Mono', weight = 'Regular' },
  { family = 'SauceCodePro Nerd Font Mono', weight = 'Regular' },
  { family = 'IosevkaTerm Nerd Font Mono', weight = 'Regular' },
  { family = 'Lilex Nerd Font Mono', weight = 'Regular' },
  { family = 'Symbols Nerd Font Mono', weight = 'Regular' },
})

M.font_size = 17
M.line_height = 1.2
M.foreground_text_hsb = {
  hue = 1.0,
  saturation = 1.2,
  brightness = 1.5,
}

M.setup = function(config)
  config.font = M.font
  config.font_size = M.font_size
  config.line_height = M.line_height
  config.foreground_text_hsb = M.foreground_text_hsb
end

return M