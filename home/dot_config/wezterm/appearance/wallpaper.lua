local wezterm = require "wezterm"
local appearance = require "appearance"
local fs = require "scripts.fs"

local M = {}
local WALLPAPER_DIR = (wezterm.config_dir):gsub("\\", "/") .. '/appearance/wallpapers'
local DEFAULT_BG_OPACITY = 0.95
local OVERLAY_OPACITY = 0.55

local function get_wallpapers()
  wezterm.log_info("wallpaper: reading dir " .. WALLPAPER_DIR)
  local entries = fs.read_dir(WALLPAPER_DIR)
  if not entries then
    wezterm.log_info("wallpaper: cant read dir, returning empty")
    return {}
  end

  local types = {}
  for _, path in ipairs(entries) do
    local name = fs.basename(path)
    if not name:match("^%.") then table.insert(types, name) end
  end
  wezterm.log_info("wallpaper: found types: " .. table.concat(types, ", "))

  local wallpapers = {}
  for _, t in ipairs(types) do
    wallpapers[t] = {}
    local sub = WALLPAPER_DIR .. '/' .. t
    local files = fs.read_dir(sub)
    if files then
      for _, path in ipairs(files) do
        local filename = fs.basename(path)
        if not filename:match("^%.") then table.insert(wallpapers[t], filename) end
      end
    end
    wezterm.log_info("wallpaper: type '" .. t .. "' files: " .. table.concat(wallpapers[t] or {}, ", "))
    if #wallpapers[t] == 0 then wallpapers[t] = nil end
  end
  return wallpapers
end

local function background_with_overlay(image_path, opacity)
  return {
    {
      source = { File = image_path },
      opacity = opacity or DEFAULT_BG_OPACITY,
    },
    {
      source = { Color = "#0f172a" },
      width = "100%",
      height = "100%",
      opacity = OVERLAY_OPACITY,
    },
  }
end

local function ensure_loaded(g)
  if g._wallpapers_loaded then
    wezterm.log_info("wallpaper: already loaded")
    return
  end
  wezterm.log_info("wallpaper: loading...")
  g.wallpapers = get_wallpapers()
  g._wallpapers_loaded = true
  local types = {}
  for name, _ in pairs(g.wallpapers) do table.insert(types, name) end
  table.sort(types)
  wezterm.log_info("wallpaper: loaded types=" .. table.concat(types, ",") .. " current=" .. (g.current_wallpaper_type or "nil"))
  if #types > 0 then g.current_wallpaper_type = types[1] end
  wezterm.log_info("wallpaper: current_type after assign=" .. (g.current_wallpaper_type or "nil"))
end

local function cycle_wallpaper_type(g)
  local types = {}
  for name in pairs(g.wallpapers) do table.insert(types, name) end
  table.sort(types)
  if #types == 0 then return false end

  local current_idx = 1
  for i, name in ipairs(types) do
    if name == g.current_wallpaper_type then current_idx = i; break end
  end

  g.current_wallpaper_type = types[(current_idx % #types) + 1]
  g.selected_wallpaper = 1
  return true
end

local function cycle_wallpaper_startup(config, g)
  if not g.current_wallpaper_type then return end
  local images = g.wallpapers[g.current_wallpaper_type]
  if not images or #images == 0 then return end
  local path = WALLPAPER_DIR .. '/' .. g.current_wallpaper_type .. '/' .. images[1]
  config.background = background_with_overlay(path, DEFAULT_BG_OPACITY)
  wezterm.log_info("wallpaper: applied startup wallpaper " .. path)
end

local function cycle_wallpaper(g, window)
  wezterm.log_info("wallpaper: cycle_wallpaper called")
  if not g.current_wallpaper_type then
    wezterm.log_info("wallpaper: no current_type, aborting")
    return
  end
  local images = g.wallpapers[g.current_wallpaper_type]
  wezterm.log_info("wallpaper: type=" .. g.current_wallpaper_type .. " images=" .. table.concat(images or {}, ",") .. " selected=" .. g.selected_wallpaper)
  if not images or #images == 0 then
    wezterm.log_info("wallpaper: no images, aborting")
    return
  end

  local overrides = window:get_config_overrides() or {}
  local current_opacity = DEFAULT_BG_OPACITY
  if overrides.background and overrides.background[1] then
    current_opacity = overrides.background[1].opacity or DEFAULT_BG_OPACITY
  end

  local path = WALLPAPER_DIR .. '/' .. g.current_wallpaper_type .. '/' .. images[g.selected_wallpaper]
  wezterm.log_info("wallpaper: setting path=" .. path .. " opacity=" .. current_opacity)
  overrides.background = background_with_overlay(path, current_opacity)
  window:set_config_overrides(overrides)
  wezterm.log_info("wallpaper: overrides applied")

  g.selected_wallpaper = (g.selected_wallpaper % #images) + 1
  wezterm.log_info("wallpaper: next selected=" .. g.selected_wallpaper)
end

function M.setup(config, g, colors)
  wezterm.log_info("wallpaper: M.setup called, config_dir=" .. (wezterm.config_dir or "nil"))

  g.wallpapers = g.wallpapers or {}
  g.current_wallpaper_type = g.current_wallpaper_type or nil
  g.selected_wallpaper = g.selected_wallpaper or 1

  wezterm.on('cycle-wallpaper', function(window, _)
    wezterm.log_info("wallpaper: event 'cycle-wallpaper' fired")
    ensure_loaded(g)
    cycle_wallpaper(g, window)
  end)

  wezterm.on('cycle-wallpaper-folder', function(window, _)
    wezterm.log_info("wallpaper: event 'cycle-wallpaper-folder' fired")
    ensure_loaded(g)
    if cycle_wallpaper_type(g) then
      cycle_wallpaper(g, window)
    end
  end)

  wezterm.on('clear-background', function(window, _)
    wezterm.log_info("wallpaper: event 'clear-background' fired")
    local overrides = window:get_config_overrides() or {}
    overrides.background = nil
    window:set_config_overrides(overrides)
  end)

  wezterm.on('no-wallpaper', function(window, _)
    wezterm.log_info("wallpaper: event 'no-wallpaper' fired")
    appearance.apply_base_background(window, colors)
  end)

  wezterm.on('window-config-reloaded', function(window, _)
    wezterm.log_info("wallpaper: config reloaded, restoring appearance background")
    if not appearance.should_start_with_wallpaper() then
      appearance.apply_base_background(window, colors)
    end
  end)

  -- Load wallpapers for cycling; appearance decides whether startup uses one.
  ensure_loaded(g)
  if appearance.should_start_with_wallpaper() then
    cycle_wallpaper_startup(config, g)
  end
end

return M
