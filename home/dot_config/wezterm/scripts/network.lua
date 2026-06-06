local wezterm = require "wezterm"
local fs = require "scripts.fs"
local platform = require "scripts.platform"

local M = {}

local function is_vpn_interface(name)
  return name:match("^tun")
    or name:match("^tap")
    or name:match("^wg")
    or name:match("^ppp")
    or name:match("^zt")
    or name:find("tailscale") ~= nil
end

local function is_linux_vpn_active()
  local interfaces = fs.read_dir("/sys/class/net")
  if not interfaces then return false end

  for _, path in ipairs(interfaces) do
    if is_vpn_interface(fs.basename(path)) then
      return true
    end
  end

  return false
end

local function is_windows_vpn_active()
  local ok, stdout, _ = wezterm.run_child_process { 'ipconfig' }
  return ok and stdout and stdout:find('utun') ~= nil
end

function M.is_vpn_active()
  if platform.is_windows() then return is_windows_vpn_active() end
  if platform.is_linux() then return is_linux_vpn_active() end
  return false
end

return M
