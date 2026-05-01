-- ===================================================
-- Leader Key:
-- The leader key is set to ALT + q.
-- With a timeout of 2000 milliseconds (2 seconds).

-- Keybindings:
-- 1. Tab Management:
--    - LEADER + enter: Create a new tab in the current pane's domain.
--    - LEADER + return: Close the current pane (with confirmation).
--    - LEADER + <number>: Switch to a specific tab (1–9).

-- 2. Pane Splitting:
--    - LEADER + w: Split the current pane horizontally into two panes.
--    - LEADER + q: Split the current pane vertically into two panes.

-- 3. Pane Navigation:
--    - LEADER + LeftArrow: Move to the pane on the left.
--    - LEADER + DownArrow: Move to the pane below.
--    - LEADER + UpArrow: Move to the pane above.
--    - LEADER + RightArrow: Move to the pane on the right.

-- 4. Pane Resizing:
--    - LEADER + : Increase the pane size to the left by 5 units.
--    - LEADER + : Increase the pane size to the right by 5 units.
--    - LEADER + : Increase the pane size downward by 5 units.
--    - LEADER + : Increase the pane size upward by 5 units.

-- 5. Status Line:
--    - The status line indicates when the leader key is active, displaying an ocean wave emoji (🌊).

local wezterm = require "wezterm"
local act = wezterm.action

local M = {}

M.leader = { key = 'q', mods = 'ALT', timeout_milliseconds = 2000 }

M.mouse_bindings = {
  { event = { Down = { streak = 1, button = "Right" } }, mods = "NONE", action = act.CopyTo("Clipboard") },
  { event = { Down = { streak = 1, button = "Middle" } }, mods = "NONE", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { event = { Down = { streak = 1, button = "Middle" } }, mods = "SHIFT", action = act.CloseCurrentPane { confirm = false } },
}

M.setup = function(config)
  config.keys = {}
  config.leader = M.leader
  config.mouse_bindings = M.mouse_bindings

  -- LEADER bindings
  for _, v in ipairs({
    { "Enter", act.SpawnTab "CurrentPaneDomain" },
    { "Backspace", act.CloseCurrentPane { confirm = false } },
    { "q", act.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { "w", act.SplitVertical { domain = "CurrentPaneDomain" } },
    { "LeftArrow", act.ActivatePaneDirection "Left" },
    { "RightArrow", act.ActivatePaneDirection "Right" },
    { "UpArrow", act.ActivatePaneDirection "Up" },
    { "DownArrow", act.ActivatePaneDirection "Down" },
    { "=", act.IncreaseFontSize },
    { "-", act.DecreaseFontSize },
    { "0", act.ResetFontSize },
    { "z", act.TogglePaneZoomState },
    { "f", act.ToggleFullScreen },
  }) do
    table.insert(config.keys, { mods = "LEADER", key = v[1], action = v[2] })
  end

  -- LEADER+SHIFT bindings
  table.insert(config.keys, {
    mods = "LEADER|SHIFT",
    key = "Enter",
    action = wezterm.action_callback(function(win, pane)
      pane:move_to_new_tab()
    end),
  })

  -- CTRL+SHIFT bindings
  for _, v in ipairs({
    { "c", act.CopyTo("ClipboardAndPrimarySelection") },
    { "v", act.PasteFrom("Clipboard") },
  }) do
    table.insert(config.keys, { mods = "CTRL|SHIFT", key = v[1], action = v[2] })
  end

  --   {"LeftArrow", act.AdjustPaneSize { "Left", 5 }},
  --   {"RightArrow", act.AdjustPaneSize { "Right", 5 }},
  --   {"UpArrow", act.AdjustPaneSize { "Up", 5 }},
  --   {"DownArrow", act.AdjustPaneSize { "Down", 5 }},
  --   {"z", act.TogglePaneZoomState},
  --   {"=", act.PaneSelect{mode='SwapWithActive'}},

  -- CTRL+SHIFT+ALT: move tabs
  for _, v in ipairs({
    { "LeftArrow", act.MoveTabRelative(-1) },
    { "RightArrow", act.MoveTabRelative(1) },
  }) do
    table.insert(config.keys, { mods = "CTRL|SHIFT|ALT", key = v[1], action = v[2] })
  end

  -- Tab switching (LEADER + 1-9)
  for i = 1, 9 do
    table.insert(config.keys, { key = tostring(i), mods = "LEADER", action = act.ActivateTab(i - 1) })
  end

  --table.insert(config.keys, { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentTab { confirm = true } })
  --table.insert(config.keys, { key = 'r', mods = 'CTRL|SHIFT', action = act.ReloadConfiguration })

end

-- -- WSL new tab (SpawnTab with domain)
-- if first_wsl_name then
--   table.insert(config.keys, {
--     key = 'w', mods = 'CTRL|ALT',
--     action = act.SpawnTab { DomainName = first_wsl_name },
--   })
-- else
--   table.insert(config.keys, {
--     key = 'w', mods = 'CTRL|ALT',
--     action = act.SpawnCommandInNewTab { args = { 'wsl.exe' } },
--   })
-- end

-- -- PowerShell new tab in Windows domain (no vanish)
-- if has_pwsh then
--   table.insert(config.keys, {
--     key = 'p', mods = 'CTRL|ALT',
--     action = act.SpawnCommandInNewTab {
--       domain = { DomainName = "local" },
--       args = { 'pwsh.exe', '-NoLogo' },
--     },
--   })
-- elseif has_powershell then
--   table.insert(config.keys, {
--     key = 'p', mods = 'CTRL|ALT',
--     action = act.SpawnCommandInNewTab {
--       domain = { DomainName = "local" },
--       args = { 'powershell.exe', '-NoLogo' },
--     },
--   })
-- end

-- -- cmd new tab in Windows domain (no vanish)
-- if has_cmd then
--   table.insert(config.keys, {
--     key = 'c', mods = 'CTRL|ALT',
--     action = act.SpawnCommandInNewTab {
--       domain = { DomainName = "local" },
--       args = { 'cmd.exe' },
--     },
--   })
-- end

return M