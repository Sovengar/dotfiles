local wezterm = require "wezterm"
local platform = require "scripts.platform"
local system = require "scripts.system"

local M = {}

M.setup = function(config)
  config.default_domain = 'local'
  
  local has_pwsh = system.exe_exists('pwsh.exe')
  local has_powershell = system.exe_exists('powershell.exe')
  local has_cmd = system.exe_exists('cmd.exe')

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

  if not platform.is_windows() then
    config.default_prog = { "fish" }
    return
  else -- Windows
    config.default_prog = { "pwsh.exe", "-NoLogo" }
      -- if #wsl_domains > 0 then
      --   first_wsl_name = wsl_domains[1].name -- e.g. "WSL:Ubuntu-22.04"
      --   config.default_domain = first_wsl_name
      -- end
  end

end

return M
