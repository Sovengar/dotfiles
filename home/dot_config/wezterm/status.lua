local wezterm = require "wezterm"
local cache = require "scripts.cache"
local network = require "scripts.network"
local system = require "scripts.system"

local M = {}

local function is_ssh_active(pane)
  local process_name = pane:get_foreground_process_name()
  if process_name and process_name:lower():find("ssh") then
    return true
  end
  local user_vars = pane:get_user_vars()
  return user_vars.SSH_MOCK == "1"
end

M.setup = function(theme)
  local styles = {
    highlight = theme.active_status.fg_color,
    dim = theme.inactive_status.fg_color,
  }

  wezterm.on("update-status", function(window, pane)
    local cells = {}

    if window:leader_is_active() then
      table.insert(cells, { Foreground = { Color = styles.highlight } })
      table.insert(cells, { Text = ' 󰬓 ' })
    end

    local ssh_active = is_ssh_active(pane)
    local ssh_color = ssh_active and styles.highlight or styles.dim
    table.insert(cells, { Foreground = { Color = ssh_color } })
    table.insert(cells, { Text = ' 󰲝󰣀 ' })

    local vpn_active = network.is_vpn_active()
    local vpn_color = vpn_active and styles.highlight or styles.dim
    table.insert(cells, { Foreground = { Color = vpn_color } })
    table.insert(cells, { Text = ' 󱘖 ' })

    local dark_mode = system.is_dark_mode()
    local mode_color = dark_mode and styles.highlight or styles.dim
    table.insert(cells, { Foreground = { Color = mode_color } })
    table.insert(cells, { Text = ' 󰔎 ' })

    local cpu, mem = system.get_system_stats()
    table.insert(cells, { Foreground = { Color = styles.dim } })
    table.insert(cells, { Text = ' 󰻠 ' .. cpu .. '%' })
    table.insert(cells, { Foreground = { Color = styles.dim } })
    table.insert(cells, { Text = ' 󰾭 ' .. mem .. '%' })

    local battery = cache.get('battery', 30, system.get_battery)
    if battery then
      table.insert(cells, { Foreground = { Color = styles.dim } })
      table.insert(cells, { Text = battery })
    end

    local time_str = os.date('%H:%M')
    table.insert(cells, { Foreground = { Color = styles.dim } })
    table.insert(cells, { Text = '  ' .. time_str })

    window:set_right_status(wezterm.format(cells))
  end)
end

return M
