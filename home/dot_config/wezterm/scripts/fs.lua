local wezterm = require "wezterm"

local M = {}

function M.basename(path)
  return tostring(path):gsub("(.*[/\\])(.*)", "%2")
end

function M.normalize_path(path)
  if not path then return nil end

  local value = tostring(path)
  value = value:gsub("^file://", "")
  value = value:gsub("\\", "/")
  value = value:gsub("^/", "")
  value = value:gsub("/$", "")
  return value
end

function M.read_file(path)
  local file = io.open(path, "r")
  if not file then return nil end

  local content = file:read("*a")
  file:close()
  return content
end

function M.read_dir(path)
  local ok, entries = pcall(wezterm.read_dir, path)
  if not ok then return nil end
  return entries
end

function M.trim(value)
  return value and value:gsub("^%s+", ""):gsub("%s+$", "") or nil
end

return M
