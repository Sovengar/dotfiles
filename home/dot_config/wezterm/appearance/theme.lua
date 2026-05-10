local wezterm = require "wezterm"
local icons = require "appearance.icons"

local M = {}

-- [[ CONFIGURACIÓN PRINCIPAL ]]
local config = {
  use_rombos = true,            -- true: estilo romboide, false: estilo minimal (sin fondos ni iconos)
  active_palette = "yellowish", -- "yellowish" o "github_dark"
}

M.scheme_name = "tokyonight_night"

-- Intentar obtener el esquema, si no existe usar uno por defecto para no crashear
local builtin_schemes = wezterm.get_builtin_color_schemes()
local scheme = builtin_schemes[M.scheme_name]

if scheme then
  scheme.ansi[4] = "#a855f7"
  scheme.brights[4] = "#bc8cff"
  M.scheme = scheme
else
  -- Fallback si no encuentra el esquema especificado
  M.scheme = builtin_schemes["Tokyo Night"] or builtin_schemes["Batman"]
end

-- 1. Definición de Paletas de Colores
local palettes = {
  yellowish = {
    primary = "#FBB829",        -- Color principal para texto en minimal
    primary_hover = "#FF8700",  -- Color hover para texto en minimal
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
    primary = "#8b5cf6",        -- Color principal para texto en minimal (Purple)
    primary_hover = "#4d7dd8",  -- Color hover para texto en minimal (Blue)
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

local p = palettes[config.active_palette]

-- 2. Definición de Colores Base
M.colors = {
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

-- 3. Lógica de Aplicación de Estilo (Rombos vs Minimal)
M.colors.tab_bar_bg = "none"

-- Estilo de los tabs
M.colors.active_tab = { 
  bg_color = config.use_rombos and p.active.bg or "none", 
  fg_color = config.use_rombos and p.active.fg or p.primary 
}
M.colors.inactive_tab = { 
  bg_color = config.use_rombos and p.inactive.bg or "none", 
  fg_color = config.use_rombos and p.inactive.fg or "#9399b2" 
}
M.colors.tab_hover = { 
  bg_color = config.use_rombos and p.hover.bg or "none", 
  fg_color = config.use_rombos and p.hover.fg or p.primary_hover 
}
M.colors.new_tab = p.new.fg
M.colors.new_tab_hover = p.new_hover.fg

-- Iconos de los bordes
M.colors.tab_style = {
  left_most = config.use_rombos and icons.left_most or ' ',
  left_arrow = config.use_rombos and icons.left_arrow or ' ',
  right_arrow = config.use_rombos and icons.right_arrow or ' ',
}

-- Colores de los bordes (Edges)
M.colors.active_right_edge_lower = "none"
M.colors.active_right_edge_upper = config.use_rombos and p.active.bg or "none"
M.colors.active_left_edge_lower = config.use_rombos and p.active.bg or "none"
M.colors.active_left_edge_upper = "none"

M.colors.inactive_right_edge_lower = "none"
M.colors.inactive_right_edge_upper = config.use_rombos and p.inactive.bg or "none"
M.colors.inactive_left_edge_lower = config.use_rombos and p.inactive.bg or "none"
M.colors.inactive_left_edge_upper = "none"

M.colors.hover_right_edge_lower = "none"
M.colors.hover_right_edge_upper = config.use_rombos and p.hover.bg or "none"
M.colors.hover_left_edge_lower = config.use_rombos and p.hover.bg or "none"
M.colors.hover_left_edge_upper = "none"

-- Indicadores y Status
M.colors.active_unseen = { 
  bg_color = config.use_rombos and p.active.bg or "none", 
  fg_color = config.use_rombos and p.active.fg or p.primary 
}
M.colors.inactive_unseen = { 
  bg_color = config.use_rombos and p.inactive.bg or "none", 
  fg_color = config.use_rombos and p.inactive.fg or p.unseen 
}
M.colors.hover_unseen = { 
  bg_color = config.use_rombos and p.hover.bg or "none", 
  fg_color = config.use_rombos and p.hover.fg or p.primary_hover 
}

M.colors.active_bell = { 
  bg_color = config.use_rombos and p.active.bg or "none", 
  fg_color = config.use_rombos and p.active.fg or p.bell 
}
M.colors.inactive_bell = { 
  bg_color = config.use_rombos and p.inactive.bg or "none", 
  fg_color = config.use_rombos and p.inactive.fg or p.bell 
}
M.colors.hover_bell = { 
  bg_color = config.use_rombos and p.hover.bg or "none", 
  fg_color = config.use_rombos and p.hover.fg or p.bell 
}

M.colors.active_status = { bg_color = "none", fg_color = p.status }
M.colors.inactive_status = { bg_color = "none", fg_color = "#9399b2" }

return M