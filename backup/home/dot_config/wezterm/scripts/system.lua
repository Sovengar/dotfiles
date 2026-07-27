local wezterm = require "wezterm"
local fs = require "scripts.fs"
local platform = require "scripts.platform"

local M = {}
local linux_cpu_total = nil
local linux_cpu_idle = nil

local function get_linux_cpu_usage()
  local stat = fs.read_file("/proc/stat")
  if not stat then return "N/A" end

  local fields = {}
  local line = stat:match("^cpu%s+([^\n]+)")
  if line then
    for value in line:gmatch("%d+") do
      table.insert(fields, tonumber(value))
    end
  end

  if #fields < 4 then return "N/A" end

  local total = 0
  for _, value in ipairs(fields) do
    total = total + value
  end

  local idle = fields[4] + (fields[5] or 0)
  local cpu = "0"
  if linux_cpu_total and total > linux_cpu_total then
    local total_delta = total - linux_cpu_total
    local idle_delta = idle - linux_cpu_idle
    cpu = tostring(math.floor(((total_delta - idle_delta) / total_delta) * 100 + 0.5))
  end

  linux_cpu_total = total
  linux_cpu_idle = idle
  return cpu
end

local function get_linux_memory_usage()
  local meminfo = fs.read_file("/proc/meminfo")
  if not meminfo then return "N/A" end

  local total = tonumber(meminfo:match("MemTotal:%s+(%d+)"))
  local available = tonumber(meminfo:match("MemAvailable:%s+(%d+)")) or tonumber(meminfo:match("MemFree:%s+(%d+)"))
  if not total or not available or total <= 0 then return "N/A" end

  return tostring(math.floor(((total - available) / total) * 100 + 0.5))
end

local function get_windows_system_stats()
  local ok, stdout, _ = wezterm.run_child_process {
    'powershell', '-NoProfile', '-Command',
    '$cpu=(Get-CimInstance Win32_Processor).LoadPercentage; $os=Get-CimInstance Win32_OperatingSystem; $used=($os.TotalVisibleMemorySize-$os.FreePhysicalMemory)/$os.TotalVisibleMemorySize*100; Write-Output "$cpu $([math]::Round($used))"'
  }
  if not ok or not stdout then return "N/A", "N/A" end

  local cpu, mem = stdout:match("(%d+)%s+(%d+)")
  return cpu or "N/A", mem or "N/A"
end

local function get_linux_battery()
  local supplies = fs.read_dir("/sys/class/power_supply")
  if not supplies then return nil end

  for _, path in ipairs(supplies) do
    local name = fs.basename(path)
    if name:match("^BAT") then
      local base = "/sys/class/power_supply/" .. name
      local charge = fs.trim(fs.read_file(base .. "/capacity"))
      local status = fs.trim(fs.read_file(base .. "/status"))
      if charge then
        local icon = status == "Charging" and ' 󱟨 ' or ' 󰁹 '
        return icon .. charge .. "%"
      end
    end
  end

  return nil
end

local function get_windows_battery()
  local ok, stdout, _ = wezterm.run_child_process {
    'powershell', '-NoProfile', '-Command',
    '$b=Get-CimInstance Win32_Battery; if($b){Write-Output "$($b.EstimatedChargeRemaining) $($b.BatteryStatus)"}'
  }
  if not ok or not stdout then return nil end

  local charge, status = stdout:match("(%d+)%s+(%d+)")
  if not charge or not status then return nil end

  local icon = status == "2" and ' 󱟨 ' or ' 󰁹 '
  return icon .. charge .. "%"
end

function M.get_cpu_usage()
  if platform.is_linux() then return get_linux_cpu_usage() end
  if platform.is_windows() then
    local cpu, _ = get_windows_system_stats()
    return cpu
  end
  return "N/A"
end

function M.get_memory_usage()
  if platform.is_linux() then return get_linux_memory_usage() end
  if platform.is_windows() then
    local _, mem = get_windows_system_stats()
    return mem
  end
  return "N/A"
end

function M.get_system_stats()
  if platform.is_linux() then
    return get_linux_cpu_usage(), get_linux_memory_usage()
  end
  if platform.is_windows() then return get_windows_system_stats() end
  return "N/A", "N/A"
end

function M.get_battery()
  if platform.is_linux() then return get_linux_battery() end
  if platform.is_windows() then return get_windows_battery() end
  return nil
end

function M.exe_exists(name)
  local command = platform.is_windows() and 'where' or 'which'
  local ok, _stdout, _stderr = wezterm.run_child_process { command, name }
  return ok
end

function M.is_dark_mode()
  if not platform.is_windows() then return false end

  local ok, stdout, _ = wezterm.run_child_process { 'reg', 'query', 'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize', '/v', 'AppsUseLightTheme' }
  return ok and stdout and stdout:find('0x0') ~= nil
end

return M
