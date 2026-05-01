local wezterm = require "wezterm"

local M = {}

M.scheme_name = "tokyonight_night"

local scheme = wezterm.get_builtin_color_schemes()[M.scheme_name]
scheme.ansi[4] = "#a855f7"
scheme.brights[4] = "#bc8cff"

M.scheme = scheme

-- All colors in one palette
M.colors = {
  -- GitHub Dark
  fg = "#d0d7de",
  bg = "#0d1117",
  comment = "#8b949e",
  red = "#ff7b72",
  green = "#3fb950",
  magenta = "#a855f7",
  blue = "#539bf5",
  magenta_bright = "#bc8cff",
  cyan = "#39c5cf",
  selection = "#415555",
  caret = "#58a6ff",
  invisibles = "#2f363d",
  -- Derived from Catppuccin
  border = "#b7bdf8",
  tab_bar_active_tab_fg = "#c6a0f6",
  tab_bar_active_tab_bg = "#181926",
  tab_bar_text = "#181926",
  arrow_foreground_leader = "#b7bdf8",
  arrow_background_leader = "#181926",

  -- Tab colors (Yellowish)
  tab_bar_bg = "none",
  active_tab = { bg_color = "#FBB829", fg_color = "#1C1B19" },
  inactive_tab = { bg_color = "#4E4E4E", fg_color = "#1C1B19" },
  tab_hover = { bg_color = "#FF8700", fg_color = "#1C1B19" },
  new_tab = { bg_color = "none", fg_color = "#FCE8C3", intensity = "Bold" },
  new_tab_hover = { bg_color = "none", fg_color = "#FBB829", intensity = "Bold" },
  tab_edge = "#FBB829",

  inactive_unseen = { bg_color = "#FBB829", fg_color = "#6b7280" },
  hover_unseen = { bg_color = "#FF8700", fg_color = "#4d7dd8" },
  inactive_bell = { bg_color = "#4E4E4E", fg_color = "#fbbf24" },
  hover_bell = { bg_color = "#FF8700", fg_color = "#fbbf24" },
}

return M
