local wezterm = require "wezterm"

local M = {}

function M.is_linux()
  return wezterm.target_triple:find("linux") ~= nil
end

function M.is_windows()
  return wezterm.target_triple:find("windows") ~= nil
end

function M.is_macos()
  return wezterm.target_triple:find("darwin") ~= nil
end

function M.is_wayland()
  return os.getenv("WAYLAND_DISPLAY") ~= nil or os.getenv("XDG_SESSION_TYPE") == "wayland"
end

function M.is_linux_wayland()
  return M.is_linux() and M.is_wayland()
end

function M.get_windows_build_number()
  if not M.is_windows() or type(wezterm.os_release_info) ~= "function" then
    return nil
  end

  local info = wezterm.os_release_info()
  return info and info.build_number and tonumber(info.build_number) or nil
end

function M.is_windows_10()
  local build_number = M.get_windows_build_number()
  return build_number ~= nil and build_number >= 10240 and build_number < 22000
end

function M.is_windows_11()
  local build_number = M.get_windows_build_number()
  return build_number ~= nil and build_number >= 22000
end

return M
