local wezterm = require "wezterm"
local act = wezterm.action
local quickterm = require "quickterm"

local M = {}

M.leader = { key = 'q', mods = 'ALT', timeout_milliseconds = 2000 }

M.mouse_bindings = {
  { event = { Down = { streak = 1, button = "Right" } }, mods = "NONE", action = act.CopyTo("Clipboard") },
  { event = { Down = { streak = 1, button = "Middle" } }, mods = "NONE", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { event = { Down = { streak = 1, button = "Middle" } }, mods = "SHIFT", action = act.CloseCurrentPane { confirm = false } },
}

-- Single source of truth: { mods, key, action, desc }
M.bindings = {
  -- LEADER
  { mods = "LEADER",        key = "Enter",        action = act.SpawnTab "CurrentPaneDomain",                                desc = "New tab" },
  { mods = "LEADER",        key = "Backspace",    action = act.CloseCurrentPane { confirm = false },                       desc = "Close current pane" },
  { mods = "LEADER",        key = "q",            action = act.SplitHorizontal { domain = "CurrentPaneDomain" },            desc = "Split pane horizontally" },
  { mods = "LEADER",        key = "w",            action = act.SplitVertical { domain = "CurrentPaneDomain" },              desc = "Split pane vertically" },
  { mods = "LEADER",        key = "LeftArrow",    action = act.ActivatePaneDirection "Left",                                desc = "Move to left pane" },
  { mods = "LEADER",        key = "RightArrow",   action = act.ActivatePaneDirection "Right",                               desc = "Move to right pane" },
  { mods = "LEADER",        key = "UpArrow",      action = act.ActivatePaneDirection "Up",                                  desc = "Move to pane above" },
  { mods = "LEADER",        key = "DownArrow",    action = act.ActivatePaneDirection "Down",                                desc = "Move to pane below" },
  { mods = "LEADER",        key = "=",            action = act.IncreaseFontSize,                                            desc = "Increase font size" },
  { mods = "LEADER",        key = "-",            action = act.DecreaseFontSize,                                            desc = "Decrease font size" },
  { mods = "LEADER",        key = "0",            action = act.ResetFontSize,                                               desc = "Reset font size" },
  { mods = "LEADER",        key = "z",            action = act.TogglePaneZoomState,                                         desc = "Toggle pane zoom" },
  { mods = "LEADER",        key = "f",            action = act.ToggleFullScreen,                                            desc = "Toggle full screen" },

  -- LEADER+SHIFT
  { mods = "LEADER|SHIFT",  key = "Enter",        action = wezterm.action_callback(function(win, pane) pane:move_to_new_tab() end), desc = "Move pane to new tab" },
  { mods = "LEADER|SHIFT",  key = "Backspace",    action = act.QuitApplication,                                             desc = "Quit WezTerm" },
  { mods = "LEADER|SHIFT",  key = "t",            action = act.EmitEvent('toggle-light-mode'),                              desc = "Toggle light/dark mode" },
  { mods = "LEADER|SHIFT",  key = "LeftArrow",    action = act.MoveTabRelative(-1),                                         desc = "Move tab left" },
  { mods = "LEADER|SHIFT",  key = "RightArrow",   action = act.MoveTabRelative(1),                                          desc = "Move tab right" },
  { mods = "LEADER|SHIFT",  key = "UpArrow",      action = act.MoveTabRelative(-1),                                         desc = "Move tab left (alt)" },
  { mods = "LEADER|SHIFT",  key = "DownArrow",    action = act.MoveTabRelative(1),                                          desc = "Move tab right (alt)" },
  { mods = "LEADER|SHIFT",  key = "r",            action = act.ReloadConfiguration,                                         desc = "Reload configuration" },
  { mods = "LEADER|SHIFT",  key = "[",            action = act.EmitEvent('opacity-dec'),                                    desc = "Decrease opacity" },
  { mods = "LEADER|SHIFT",  key = "]",            action = act.EmitEvent('opacity-inc'),                                    desc = "Increase opacity" },
  { mods = "LEADER|SHIFT",  key = "o",            action = act.EmitEvent('toggle-transparency'),                            desc = "Toggle transparency" },
  { mods = "LEADER|SHIFT",  key = "n",            action = act.EmitEvent('cycle-wallpaper-folder'),                         desc = "Cycle wallpaper folder" },
  { mods = "LEADER|SHIFT",  key = "b",            action = act.EmitEvent('cycle-wallpaper'),                                desc = "Cycle wallpaper image" },
  { mods = "LEADER|SHIFT",  key = "v",            action = act.EmitEvent('clear-background'),                               desc = "Clear wallpaper background" },

  -- LEADER+CTRL+SHIFT
  { mods = "LEADER|CTRL|SHIFT", key = "LeftArrow",  action = act.AdjustPaneSize { "Left", 5 },                             desc = "Resize pane left" },
  { mods = "LEADER|CTRL|SHIFT", key = "RightArrow", action = act.AdjustPaneSize { "Right", 5 },                            desc = "Resize pane right" },
  { mods = "LEADER|CTRL|SHIFT", key = "UpArrow",    action = act.AdjustPaneSize { "Up", 5 },                               desc = "Resize pane up" },
  { mods = "LEADER|CTRL|SHIFT", key = "DownArrow",  action = act.AdjustPaneSize { "Down", 5 },                             desc = "Resize pane down" },

  -- CTRL+SHIFT
  { mods = "CTRL|SHIFT",    key = "c",            action = act.CopyTo("ClipboardAndPrimarySelection"),                      desc = "Copy to clipboard" },
  { mods = "CTRL|SHIFT",    key = "v",            action = act.PasteFrom("Clipboard"),                                      desc = "Paste from clipboard" },
  { mods = "CTRL|SHIFT",    key = "t",            action = wezterm.action_callback(function(win, pane) quickterm.toggle(win, pane) end), desc = "Toggle quickterm" },

  -- Tab switching (LEADER + 1-9)
  { mods = "LEADER", key = "1", action = act.ActivateTab(0), desc = "Switch to tab 1" },
  { mods = "LEADER", key = "2", action = act.ActivateTab(1), desc = "Switch to tab 2" },
  { mods = "LEADER", key = "3", action = act.ActivateTab(2), desc = "Switch to tab 3" },
  { mods = "LEADER", key = "4", action = act.ActivateTab(3), desc = "Switch to tab 4" },
  { mods = "LEADER", key = "5", action = act.ActivateTab(4), desc = "Switch to tab 5" },
  { mods = "LEADER", key = "6", action = act.ActivateTab(5), desc = "Switch to tab 6" },
  { mods = "LEADER", key = "7", action = act.ActivateTab(6), desc = "Switch to tab 7" },
  { mods = "LEADER", key = "8", action = act.ActivateTab(7), desc = "Switch to tab 8" },
  { mods = "LEADER", key = "9", action = act.ActivateTab(8), desc = "Switch to tab 9" },
}

function M.setup(config)
  config.keys = {}
  config.leader = M.leader
  config.mouse_bindings = M.mouse_bindings
  for _, b in ipairs(M.bindings) do
    table.insert(config.keys, { mods = b.mods, key = b.key, action = b.action })
  end
end

wezterm.on('augment-command-palette', function()
  local entries = {}
  for _, b in ipairs(M.bindings) do
    local mods_display = b.mods:gsub("LEADER", "ALT+q")
    table.insert(entries, {
      brief = string.format("%-24s %s", mods_display, b.desc),
      icon = "md_keyboard",
      action = wezterm.action_callback(function() end),
    })
  end
  return entries
end)

return M