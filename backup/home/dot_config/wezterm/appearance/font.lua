local wezterm = require "wezterm"

local M = {}

local function read_file(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return content
end

local function resolve_symlink(path)
  local cmd = 'readlink -f "' .. path .. '"'
  local handle = io.popen(cmd, "r")
  if not handle then return nil end
  local result = handle:read("*l")
  handle:close()
  return result
end

local function parse_terminal_theme(path)
  local content = read_file(path)
  if not content then return nil end

  local result = {}
  for line in content:gmatch("[^\r\n]+") do
    local key, value = line:match("^([%w_]+)%s+(.+)$")
    if key and value then
      result[key] = value:match("^%s*(.-)%s*$")
    end
  end
  return result
end

local function get_current_theme_font()
  local state_home = os.getenv("XDG_STATE_HOME") or (wezterm.home_dir .. "/.local/state")
  local wallpaper_path = state_home .. "/hypr/wallpaper"

  local wc = read_file(wallpaper_path)
  if not wc then return nil end

  local resolved = resolve_symlink(wallpaper_path)
  if not resolved then return nil end

  local theme_name = resolved:match("themes/(.+)/wallpapers/")
  if not theme_name then return nil end

  local theme_dir = wezterm.home_dir .. "/.local/share/hyde/themes/" .. theme_name
  local terminal_theme_path = theme_dir .. "/terminal.theme"

  local theme_config = parse_terminal_theme(terminal_theme_path)
  if not theme_config then return nil end

  return theme_config.font_family, theme_config.font_size, theme_config.font_weight
end

local font_family, font_size, font_weight = get_current_theme_font()

M.font = wezterm.font_with_fallback({
  { family = font_family or 'CaskaydiaCove Nerd Font Mono', weight = font_weight or 'Bold' },
  { family = 'JetBrainsMono Nerd Font', weight = 'Bold' },
  { family = 'JetBrainsMono Nerd Font Mono', weight = 'Bold' },
  { family = 'SauceCodePro Nerd Font Mono', weight = 'Bold' },
  { family = 'IosevkaTerm Nerd Font Mono', weight = 'Bold' },
  { family = 'Lilex Nerd Font Mono', weight = 'Bold' },
  { family = 'Symbols Nerd Font Mono', weight = 'Bold' },
})

M.font_size = font_size and tonumber(font_size) or 12
M.line_height = 1.0
M.foreground_text_hsb = {
  hue = 1.0,
  saturation = 1.2,
  brightness = 1.5,
}

M.setup = function(config)
  config.font = M.font
  config.font_size = M.font_size
  config.line_height = M.line_height
end

return M
