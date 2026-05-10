local wezterm = require "wezterm"
local act = wezterm.action

local M = {}

-- Load user configuration for auto-closeable GUI commands.
local settings = require "quickterm_settings"

-- Flatten the categorized autoCloseable table into a single list.
local autoCloseList = {}
for _, group in pairs(settings.autoCloseable) do
  for _, cmd in ipairs(group) do
    table.insert(autoCloseList, cmd)
  end
end

-- Format a Lua string array as a PowerShell array literal: @('a','b')
local function ps_array(arr)
  local items = {}
  for _, v in ipairs(arr) do
    local escaped = v:gsub("'", "''")
    table.insert(items, "'" .. escaped .. "'")
  end
  return "@(" .. table.concat(items, ", ") .. ")"
end

local autoClosePs = ps_array(autoCloseList)
local blockingFlagsPs = ps_array(settings.blockingFlags)

-- Build the PowerShell script that runs inside the quickterm pane.
-- We concatenate lines so we can inject the Lua-derived arrays.
local ps_script = table.concat({
  '. "' .. wezterm.home_dir .. '\\Documents\\PowerShell\\Microsoft.PowerShell_profile.fast.ps1"',
  "& {",
  "  $ErrorActionPreference = 'Stop'",
  "  $autoCloseList = " .. autoClosePs,
  "  $blockingFlags = " .. blockingFlagsPs,
  "",
  "  $o = \"`e[38;2;230;180;80m\"",
  "  $g = \"`e[38;2;179;177;173m\"",
  "  $r = \"`e[0m\"",
  "  Write-Host \"${o}>${r} ${g}\" -NoNewline",
  "  $cmd = Read-Host",
  "  if ($cmd) {",
  "    # Extract the base command name (skip args, respect quotes)",
  "    $tokens = [System.Management.Automation.PSParser]::Tokenize($cmd, [ref]$null)",
  "    $cmdName = if ($tokens) { $tokens[0].Content } else { '' }",
  "    $cmdName = $cmdName -replace '\\.(exe|cmd|bat|com)$',''",
  "",
  "    $shouldAutoClose = $autoCloseList -contains $cmdName",
  "",
  "    # GUI apps with blocking flags (e.g. code --wait) should stay open",
  "    if ($shouldAutoClose) {",
  "      foreach ($flag in $blockingFlags) {",
  "        if ($cmd -match [regex]::Escape($flag)) {",
  "          $shouldAutoClose = $false",
  "          break",
  "        }",
  "      }",
  "    }",
  "",
  "    $sw = [System.Diagnostics.Stopwatch]::StartNew()",
  "    $hadError = $false",
  "    try {",
  "      Invoke-Expression $cmd",
  "      if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) {",
  "        $hadError = $true",
  "      }",
  "    } catch {",
  "      Write-Error $_",
  "      $hadError = $true",
  "    }",
  "    $sw.Stop()",
  "",
  "    # Auto-close only for known GUI commands that finished cleanly",
  "    if ($shouldAutoClose -and -not $hadError) {",
  "      return",
  "    }",
  "",
  "    # Otherwise keep the pane open so the user can read the output",
  "    Write-Host \"`n[Enter to close]\"",
  "    $null = Read-Host",
  "  }",
  "}",
}, "\r\n")

-- Persistent state across config reloads.
-- WezTerm nightly requires flat string keys on GLOBAL; numeric keys or
-- nested tables raise "can only index objects using string values".
local function state_key(tab_id)
  return "quickterm_pane_" .. tostring(tab_id)
end

local function get_tab_state(tab_id)
  return wezterm.GLOBAL[state_key(tab_id)]
end

local function set_tab_state(tab_id, pane_id)
  wezterm.GLOBAL[state_key(tab_id)] = pane_id
end

function M.toggle(win, pane)
  local tab = win:active_tab()
  if not tab then return end

  local tab_id = tab:tab_id()
  local tracked_pane_id = get_tab_state(tab_id)

  -- Verify the tracked pane is still alive in this tab
  if tracked_pane_id then
    local target_pane = nil
    for _, p in ipairs(tab:panes()) do
      if p:pane_id() == tracked_pane_id then
        target_pane = p
        break
      end
    end

    if target_pane then
      -- Primary: close via action. On some nightlies this only works when
      -- no prior focus dance happened inside the same callback.
      local ok = pcall(function()
        win:perform_action(act.CloseCurrentPane { confirm = false }, target_pane)
      end)

      -- Fallback: gracefully ask the shell to exit if the action fails.
      if not ok then
        target_pane:send_text("exit\r")
      end
    end

    set_tab_state(tab_id, nil)
    return
  end

  -- Open new quickterm pane at 20% height.
  -- Nightly accepts size as a float 0.0-1.0 rather than { Percent = 20 }.
  local new_pane = pane:split {
    direction = "Bottom",
    size = 0.20,
    args = { "pwsh.exe", "-NoLogo", "-NoProfile", "-Command", ps_script },
  }

  if new_pane then
    set_tab_state(tab_id, new_pane:pane_id())
    -- Leave focus in the quickterm so the user can type immediately.
  end
end

return M
