local wezterm = require "wezterm"

local M = {}

local function is_ssh_active(pane)
  local process_name = pane:get_foreground_process_name()
  if process_name and process_name:lower():find("ssh") then
    return true
  end
  local user_vars = pane:get_user_vars()
  return user_vars.SSH_MOCK == "1"
end

local function check_vpn_status()
  local ok, stdout, _ = wezterm.run_child_process { 'ipconfig' }
  if ok and stdout and stdout:find('utun') then
    return true
  end
  return false
end

local function get_system_stats()
  local ok, stdout, _ = wezterm.run_child_process {
    'cmd', '/c', 'wmic cpu get loadpercentage /value & wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /value'
  }
  if not ok or not stdout then return 'N/A', 'N/A' end
  local cpu = stdout:match('LoadPercentage=(%d+)')
  local free, total = stdout:match('FreePhysicalMemory=(%d+).-TotalVisibleMemorySize=(%d+)')
  if cpu and free and total then
    local used = tonumber(total) - tonumber(free)
    local mem = math.floor((used / tonumber(total)) * 100)
    return cpu, tostring(mem)
  end
  return 'N/A', 'N/A'
end

local function is_dark_mode()
  local ok, stdout, _ = wezterm.run_child_process { 'reg', 'query', 'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize', '/v', 'AppsUseLightTheme' }
  if ok and stdout and stdout:find('0x0') then
    return true
  end
  return false
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

    local vpn_active = check_vpn_status()
    local vpn_color = vpn_active and styles.highlight or styles.dim
    table.insert(cells, { Foreground = { Color = vpn_color } })
    table.insert(cells, { Text = ' 󱘖 ' })

    local dark_mode = is_dark_mode()
    local mode_color = dark_mode and styles.highlight or styles.dim
    table.insert(cells, { Foreground = { Color = mode_color } })
    table.insert(cells, { Text = ' 󰔎 ' })

    local cpu, mem = get_system_stats()
    table.insert(cells, { Foreground = { Color = styles.dim } })
    table.insert(cells, { Text = ' 󰻠 ' .. cpu .. '%' })
    table.insert(cells, { Foreground = { Color = styles.dim } })
    table.insert(cells, { Text = ' 󰾭 ' .. mem .. '%' })

    local time_str = os.date('%H:%M')
    table.insert(cells, { Foreground = { Color = styles.dim } })
    table.insert(cells, { Text = '  ' .. time_str })

    window:set_right_status(wezterm.format(cells))
  end)
end

return M