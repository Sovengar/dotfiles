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

  -- TERMINAL DEFAULTS
  { mods = "CTRL",          key = "=",              action = act.IncreaseFontSize,                                  desc = "Increase font size" },
  { mods = "CTRL",          key = "-",              action = act.DecreaseFontSize,                                  desc = "Decrease font size" },
  { mods = "CTRL|SHIFT",    key = "0",              action = act.ResetFontSize,                                     desc = "Reset font size" },
  { mods = "CTRL|SHIFT",    key = "c",              action = act.CopyTo("ClipboardAndPrimarySelection"),            desc = "Copy to clipboard" },
  { mods = "CTRL|SHIFT",    key = "x",              action = wezterm.action_callback(function(win, pane)
    local sel = pane:GetSelectionTextAsGsub()
    if sel and sel ~= '' then
      win:copy_to_clipboard(sel, "ClipboardAndPrimarySelection")
      pane:SendKey({ key = "Backspace" })
    end
  end),                                                                                                                  desc = "Cut text" },
  { mods = "CTRL|SHIFT",    key = "UpArrow",        action = act.ScrollByLine(-1),                                  desc = "Scroll up one line" },
  { mods = "CTRL|SHIFT",    key = "DownArrow",      action = act.ScrollByLine(1),                                   desc = "Scroll down one line" },
  { mods = "CTRL|SHIFT",    key = "v",              action = act.PasteFrom("Clipboard"),                            desc = "Paste from clipboard" },
  { mods = "ALT",           key = "t",              action = wezterm.action_callback(function(win, pane) quickterm.toggle(win, pane) end), desc = "Toggle quickterm" },
  { mods = "ALT",           key = "f",              action = wezterm.action_callback(function() wezterm.background_child_process({ "pypr", "toggle", "fdx-floating" }) end), desc = "Open floating fdx" },
  { mods = "ALT",           key = "Backspace",      action = act.CloseCurrentPane { confirm = false },              desc = "Close current pane" },

  -- MULTIPLEXING
  --- Tab management
  { mods = "ALT",           key = "Enter",          action = act.SpawnTab "CurrentPaneDomain",                      desc = "New tab" },
  { mods = "LEADER",        key = "n",              action = act.SpawnCommandInNewTab { args = { "nu" } },          desc = "Spawn nu shell" },
  { mods = "LEADER",        key = "f",              action = act.SpawnCommandInNewTab { args = { "fish" } },        desc = "Spawn fish shell" },
  { mods = "LEADER",        key = "Z",              action = act.SpawnCommandInNewTab { args = { "zsh" } },         desc = "Spawn zsh shell" },

  { mods = "ALT",           key = "1",              action = act.ActivateTab(0),                                    desc = "Switch to tab 1" },
  { mods = "ALT",           key = "2",              action = act.ActivateTab(1),                                    desc = "Switch to tab 2" },
  { mods = "ALT",           key = "3",              action = act.ActivateTab(2),                                    desc = "Switch to tab 3" },
  { mods = "ALT",           key = "4",              action = act.ActivateTab(3),                                    desc = "Switch to tab 4" },
  { mods = "ALT",           key = "5",              action = act.ActivateTab(4),                                    desc = "Switch to tab 5" },
  { mods = "ALT",           key = "6",              action = act.ActivateTab(5),                                    desc = "Switch to tab 6" },
  { mods = "ALT",           key = "7",              action = act.ActivateTab(6),                                    desc = "Switch to tab 7" },
  { mods = "ALT",           key = "8",              action = act.ActivateTab(7),                                    desc = "Switch to tab 8" },
  { mods = "ALT",           key = "9",              action = act.ActivateTab(8),                                    desc = "Switch to tab 9" },

  --- Pane management
  { mods = "LEADER",        key = "RightArrow",     action = act.SplitHorizontal { domain = "CurrentPaneDomain" },  desc = "Split pane horizontally" },
  { mods = "LEADER",        key = "DownArrow",      action = act.SplitVertical { domain = "CurrentPaneDomain" },    desc = "Split pane vertically" },
  { mods = "ALT",           key = "LeftArrow",      action = act.ActivatePaneDirection "Left",                      desc = "Move to left pane" },
  { mods = "ALT",           key = "RightArrow",     action = act.ActivatePaneDirection "Right",                     desc = "Move to right pane" },
  { mods = "ALT",           key = "UpArrow",        action = act.ActivatePaneDirection "Up",                        desc = "Move to pane above" },
  { mods = "ALT",           key = "DownArrow",      action = act.ActivatePaneDirection "Down",                      desc = "Move to pane below" },
  { mods = "ALT",           key = "z",              action = act.TogglePaneZoomState,                               desc = "Toggle pane zoom" },

  { mods = "ALT|SHIFT",     key = "Enter",          action = wezterm.action_callback(function(win, pane) pane:move_to_new_tab() end), desc = "Move pane to new tab" },
  { mods = "ALT|SHIFT",     key = "LeftArrow",      action = act.AdjustPaneSize { "Left", 5 },                      desc = "Resize pane left" },
  { mods = "ALT|SHIFT",     key = "RightArrow",     action = act.AdjustPaneSize { "Right", 5 },                     desc = "Resize pane right" },
  { mods = "ALT|SHIFT",     key = "UpArrow",        action = act.AdjustPaneSize { "Up", 5 },                        desc = "Resize pane up" },
  { mods = "ALT|SHIFT",     key = "DownArrow",      action = act.AdjustPaneSize { "Down", 5 },                      desc = "Resize pane down" },

  { mods = "ALT|CTRL",      key = "LeftArrow",      action = act.PaneSelect {mode = "SwapWithActive"},              desc = "Move pane left" },
  { mods = "ALT|CTRL",      key = "RightArrow",     action = act.PaneSelect {mode = "SwapWithActiveKeepFocus"},     desc = "Move pane right" },
  { mods = "ALT|CTRL",      key = "UpArrow",        action = act.PaneSelect {mode = "SwapWithActive"},              desc = "Move pane up" },
  { mods = "ALT|CTRL",      key = "DownArrow",      action = act.PaneSelect {mode = "SwapWithActiveKeepFocus"},     desc = "Move pane down" },

  -- Wezterm configs
  { mods = "LEADER|SHIFT",  key = "t",              action = act.EmitEvent('toggle-light-mode'),                    desc = "Toggle light/dark mode" },
  { mods = "LEADER",        key = "r",              action = act.PromptInputLine {
    description = "Enter new name for tab",
    action = wezterm.action_callback(function(win, _pane, line)
      if line then
        win:active_tab():set_title(line)
      end
    end),
  },                                                                                                                  desc = "Rename tab" },
  { mods = "LEADER|SHIFT",  key = "r",              action = act.ReloadConfiguration,                               desc = "Reload configuration" },
  { mods = "LEADER|SHIFT",  key = "o",              action = act.EmitEvent('toggle-transparency'),                  desc = "Toggle transparency" },
  { mods = "LEADER|SHIFT",  key = "n",              action = act.EmitEvent('cycle-wallpaper-folder'),               desc = "Cycle wallpaper folder" },
  { mods = "LEADER|SHIFT",  key = "b",              action = act.EmitEvent('cycle-wallpaper'),                      desc = "Cycle wallpaper image" },
  { mods = "LEADER|SHIFT",  key = "v",              action = act.EmitEvent('clear-background'),                     desc = "Clear wallpaper background" },
  { mods = "LEADER|SHIFT",  key = "x",              action = act.EmitEvent('no-wallpaper'),                         desc = "No wallpaper (solid background)" },
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
