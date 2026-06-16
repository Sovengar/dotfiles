local wezterm = require "wezterm"
local icons = require "appearance.icons"

local M = {}

local config = {
  active_palette = "yellowish",
}

local state_home = os.getenv("XDG_STATE_HOME") or (wezterm.home_dir .. "/.local/state")
local hyde_theme_path = state_home .. "/wezterm/theme.lua"

local function file_exists(path)
  local file = io.open(path, "r")
  if not file then return false end
  file:close()
  return true
end

local function merge(base, override)
  local result = {}
  for key, value in pairs(base) do result[key] = value end
  for key, value in pairs(override or {}) do result[key] = value end
  return result
end

local function load_hyde_theme()
  if wezterm.add_to_config_reload_watch_list then
    pcall(wezterm.add_to_config_reload_watch_list, hyde_theme_path)
  end

  if not file_exists(hyde_theme_path) then return nil end

  local ok, theme = pcall(dofile, hyde_theme_path)
  if ok and type(theme) == "table" and type(theme.scheme) == "table" then
    return theme
  end

  wezterm.log_warn("Invalid HyDE WezTerm theme: " .. hyde_theme_path)
  return nil
end

local function fallback_scheme()
  local scheme_name = "tokyonight_night"
  local builtin_schemes = wezterm.get_builtin_color_schemes()
  local scheme = builtin_schemes[scheme_name]

  if scheme then
    scheme.ansi[4] = "#a855f7"
    scheme.brights[4] = "#bc8cff"
    return scheme_name, scheme
  end

  return scheme_name, builtin_schemes["Tokyo Night"] or builtin_schemes["Batman"]
end

local palettes = {
  yellowish = {
    primary = "#FBB829",
    primary_hover = "#FF8700",
    active = { bg = "#FBB829", fg = "#1C1B19" },
    inactive = { bg = "#4E4E4E", fg = "#1C1B19" },
    hover = { bg = "#FF8700", fg = "#1C1B19" },
    new = { bg = "none", fg = "#FCE8C3" },
    new_hover = { bg = "none", fg = "#FBB829" },
    bell = "#fbbf24",
    unseen = "#6b7280",
    status = "#FBB829",
  },
  github_dark = {
    primary = "#8b5cf6",
    primary_hover = "#4d7dd8",
    active = { bg = "#161b22", fg = "#8b5cf6" },
    inactive = { bg = "#161b22", fg = "#9399b2" },
    hover = { bg = "#161b22", fg = "#4d7dd8" },
    new = { bg = "none", fg = "#9399b2" },
    new_hover = { bg = "none", fg = "#4d7dd8" },
    bell = "#fbbf24",
    unseen = "#6b7280",
    status = "#8b5cf6",
  }
}

local default_colors = {
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
  border = "#b7bdf8",
  tab_bar_active_tab_fg = "#c6a0f6",
  tab_bar_active_tab_bg = "#181926",
  tab_bar_text = "#181926",
  arrow_foreground_leader = "#b7bdf8",
  arrow_background_leader = "#181926",
}

local hyde_theme = load_hyde_theme()
if hyde_theme then
  M.scheme_name = hyde_theme.scheme_name or "HyDE"
  M.scheme = hyde_theme.scheme
  M.colors = merge(default_colors, hyde_theme.colors)
else
  M.scheme_name, M.scheme = fallback_scheme()
  M.colors = default_colors
end

local fallback_palette = palettes[config.active_palette] or palettes.yellowish
local tab_palette = merge(fallback_palette, M.colors.tab or {})
tab_palette.active = merge(fallback_palette.active, tab_palette.active or {})
tab_palette.inactive = merge(fallback_palette.inactive, tab_palette.inactive or {})
tab_palette.hover = merge(fallback_palette.hover, tab_palette.hover or {})
tab_palette.new = merge(fallback_palette.new, tab_palette.new or {})
tab_palette.new_hover = merge(fallback_palette.new_hover, tab_palette.new_hover or {})

M.colors.active_status = M.colors.active_status or { bg_color = "none", fg_color = tab_palette.status }
M.colors.inactive_status = M.colors.inactive_status or { bg_color = "none", fg_color = "#9399b2" }

function M.get_tab_theme(use_rombos)
  return {
    tab_bar_bg = "none",
    active_tab = {
      bg_color = use_rombos and tab_palette.active.bg or "none",
      fg_color = use_rombos and tab_palette.active.fg or tab_palette.primary,
    },
    inactive_tab = {
      bg_color = use_rombos and tab_palette.inactive.bg or "none",
      fg_color = tab_palette.inactive.fg,
    },
    tab_hover = {
      bg_color = use_rombos and tab_palette.hover.bg or "none",
      fg_color = tab_palette.hover.fg or tab_palette.primary_hover,
    },
    new_tab = { bg_color = tab_palette.new.bg, fg_color = tab_palette.new.fg, intensity = "Bold" },
    new_tab_hover = { bg_color = tab_palette.new_hover.bg, fg_color = tab_palette.new_hover.fg, intensity = "Bold" },
    tab_style = {
      left_most = use_rombos and icons.left_most or ' ',
      left_arrow = use_rombos and icons.left_arrow or ' ',
      right_arrow = use_rombos and icons.right_arrow or ' ',
    },
    active_right_edge_lower = "none",
    active_right_edge_upper = use_rombos and tab_palette.active.bg or "none",
    active_left_edge_lower = use_rombos and tab_palette.active.bg or "none",
    active_left_edge_upper = "none",
    inactive_right_edge_lower = "none",
    inactive_right_edge_upper = use_rombos and tab_palette.inactive.bg or "none",
    inactive_left_edge_lower = use_rombos and tab_palette.inactive.bg or "none",
    inactive_left_edge_upper = "none",
    hover_right_edge_lower = "none",
    hover_right_edge_upper = use_rombos and tab_palette.hover.bg or "none",
    hover_left_edge_lower = use_rombos and tab_palette.hover.bg or "none",
    hover_left_edge_upper = "none",
    active_unseen = {
      bg_color = use_rombos and tab_palette.active.bg or "none",
      fg_color = use_rombos and tab_palette.active.fg or tab_palette.primary,
    },
    inactive_unseen = {
      bg_color = use_rombos and tab_palette.inactive.bg or "none",
      fg_color = use_rombos and tab_palette.inactive.fg or tab_palette.unseen,
    },
    hover_unseen = {
      bg_color = use_rombos and tab_palette.hover.bg or "none",
      fg_color = use_rombos and tab_palette.hover.fg or tab_palette.primary_hover,
    },
    active_bell = {
      bg_color = use_rombos and tab_palette.active.bg or "none",
      fg_color = use_rombos and tab_palette.active.fg or tab_palette.bell,
    },
    inactive_bell = {
      bg_color = use_rombos and tab_palette.inactive.bg or "none",
      fg_color = use_rombos and tab_palette.inactive.fg or tab_palette.bell,
    },
    hover_bell = {
      bg_color = use_rombos and tab_palette.hover.bg or "none",
      fg_color = use_rombos and tab_palette.hover.fg or tab_palette.bell,
    },
  }
end

return M
