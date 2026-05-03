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
  for _, v in ipairs({
    { "Enter", wezterm.action_callback(function(win, pane)
        pane:move_to_new_tab()
      end) },
    { "Backspace", act.QuitApplication },
  }) do
    table.insert(config.keys, { mods = "LEADER|SHIFT", key = v[1], action = v[2] })
  end

  -- CTRL+SHIFT bindings
  for _, v in ipairs({
    { "c", act.CopyTo("ClipboardAndPrimarySelection") },
    { "v", act.PasteFrom("Clipboard") },
  }) do
    table.insert(config.keys, { mods = "CTRL|SHIFT", key = v[1], action = v[2] })
  end

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
end

return M