local wezterm = require "wezterm"

local M = {}

-- Helper: check if executable exists in Windows PATH
local function exe_exists(name)
  local ok, _stdout, _stderr = wezterm.run_child_process { 'where', name }
  return ok
end

M.setup = function(config)
  
  local has_pwsh = exe_exists('pwsh.exe')
  local has_powershell = exe_exists('powershell.exe')
  local has_cmd = exe_exists('cmd.exe')

  -- Detect WSL distros and set default_cwd = "~" to start in Linux home
  local wsl_domains = wezterm.default_wsl_domains()
  for _, dom in ipairs(wsl_domains) do
    dom.default_cwd = "~"
  end

  local launch_menu = {}
  if has_pwsh then
    table.insert(launch_menu, {
      label = 'PowerShell (pwsh)',
      domain = { DomainName = "local" }, -- force Windows domain
      args = { 'pwsh.exe', '-NoLogo' },
    })
  end
  if has_powershell then
    table.insert(launch_menu, {
      label = 'PowerShell (Windows)',
      domain = { DomainName = "local" }, 
      args = { 'powershell.exe', '-NoLogo' },
    })
  end
  if has_cmd then
    table.insert(launch_menu, {
      label = 'Command Prompt',
      domain = { DomainName = "local" },
      args = { 'cmd.exe' },
    })
  end
  for _, dom in ipairs(wsl_domains) do
    table.insert(launch_menu, {
      label = 'WSL: ' .. dom.distribution,
      domain = { DomainName = dom.name },
    })
  end

  config.launch_menu = launch_menu

  -- if #wsl_domains > 0 then
  --   first_wsl_name = wsl_domains[1].name -- e.g. "WSL:Ubuntu-22.04"
  --   config.default_domain = first_wsl_name
  -- end

  config.default_domain = 'local'
  config.default_prog = { "pwsh.exe", "-NoLogo" }
end

return M