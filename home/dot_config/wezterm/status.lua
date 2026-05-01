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

local function get_cpu_usage()
  local ok, stdout, _ = wezterm.run_child_process { 'wmic', 'cpu', 'get', 'loadpercentage' }
  if ok and stdout then
    local cpu = stdout:match('(%d+)')
    if cpu then
      return cpu
    end
  end
  return 'N/A'
end

local function get_mem_usage()
  local ok, stdout, _ = wezterm.run_child_process { 'wmic', 'OS', 'get', 'FreePhysicalMemory,TotalVisibleMemorySize' }
  if ok and stdout then
    local free, total = stdout:match('(%d+)%s+(%d+)')
    if free and total then
      local used = tonumber(total) - tonumber(free)
      local percent = math.floor((used / tonumber(total)) * 100)
      return tostring(percent)
    end
  end
  return 'N/A'
end

local function is_dark_mode()
  local ok, stdout, _ = wezterm.run_child_process { 'reg', 'query', 'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize', '/v', 'AppsUseLightTheme' }
  if ok and stdout and stdout:find('0x0') then
    return true
  end
  return false
end

M.setup = function(colors)
  local theme = {
    highlight = colors.active_tab.fg_color,
    dim = colors.inactive_tab.fg_color,
  }

  wezterm.on("update-status", function(window, pane)
    local cells = {}

    if window:leader_is_active() then
      table.insert(cells, { Foreground = { Color = theme.highlight } })
      table.insert(cells, { Text = ' 󰬓 ' })
    end

    local ssh_active = is_ssh_active(pane)
    local ssh_color = ssh_active and theme.highlight or theme.dim
    table.insert(cells, { Foreground = { Color = ssh_color } })
    table.insert(cells, { Text = ' 󰲝󰣀 ' })

    local vpn_active = check_vpn_status()
    local vpn_color = vpn_active and theme.highlight or theme.dim
    table.insert(cells, { Foreground = { Color = vpn_color } })
    table.insert(cells, { Text = ' 󱘖 ' })

    local dark_mode = is_dark_mode()
    local mode_color = dark_mode and theme.highlight or theme.dim
    table.insert(cells, { Foreground = { Color = mode_color } })
    table.insert(cells, { Text = ' 󰔎 ' })

    local cpu = get_cpu_usage()
    table.insert(cells, { Foreground = { Color = theme.dim } })
    table.insert(cells, { Text = ' 󰻠 ' .. cpu .. '%' })

    local mem = get_mem_usage()
    table.insert(cells, { Foreground = { Color = theme.dim } })
    table.insert(cells, { Text = ' 󰾭 ' .. mem .. '%' })

    window:set_right_status(wezterm.format(cells))
  end)
end

return M