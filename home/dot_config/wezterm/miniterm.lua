--- Miniterm: Toggleable floating mini-terminal for WezTerm.
--- Opens a centered popup (~50% width, ~40% height) with CTRL+SHIFT+t.
--- Close by pressing the same key again or typing `exit` inside.

local wezterm = require "wezterm"
local act = wezterm.action

local M = {}

-- Cached pane reference for toggle detection
local mini_pane = nil

function M.toggle(current_win, current_pane)
  if mini_pane then
    local ok = pcall(M._try_focus_or_close)
    if ok then return end
    mini_pane = nil
  end

  local ok, err = pcall(M._create, current_win, current_pane)
  if not ok then
    wezterm.log_error("miniterm: failed to create: " .. tostring(err))
  end
end

function M._try_focus_or_close()
  local tab = mini_pane:tab()
  local mux_w = tab and tab:window()
  local gui = mux_w and mux_w:gui_window()
  if not (gui and tab) then
    mini_pane = nil
    error("stale pane")
  end

  if gui:is_focused() then
    gui:perform_action(act.CloseCurrentPane { confirm = false }, mini_pane)
    mini_pane = nil
    return true
  end
  gui:focus()
  return true
end

function M._create(current_win, current_pane)
  local screens = wezterm.gui.screens()
  local active = screens.active

  local target_w = math.floor(active.width * 0.50)
  local target_h = math.floor(active.height * 0.40)
  local x = math.floor(active.x + (active.width - target_w) / 2)
  local y = math.floor(active.y + (active.height - target_h) / 2)

  local tab, pane, mux_w = wezterm.mux.spawn_window {
    args = { "pwsh.exe", "-NoLogo", "-NoProfile", "-NoExit", "-Command",
      '. "' .. wezterm.home_dir .. '\\Documents\\PowerShell\\Microsoft.PowerShell_profile.fast.ps1"' }
  }
  if not pane then
    wezterm.log_error("miniterm: spawn_window returned no pane")
    return
  end

  mini_pane = pane

  local gui = mux_w and mux_w:gui_window()
  if gui then
    gui:set_config_overrides({ window_decorations = "NONE" })
    gui:perform_action(act.ToggleAlwaysOnTop, pane)
    -- Create off-screen so FancyZones snaps to nothing visible
    gui:set_position(-9999, -9999)
    gui:set_inner_size(target_w, target_h)
    -- After OS settles, position correctly (FancyZones won't re-snap moved windows)
    wezterm.time.call_after(0.05, function()
      local g2 = mux_w:gui_window()
      if g2 then
        g2:set_position(x, y)
        g2:set_inner_size(target_w, target_h)
        g2:focus()
      end
    end)
  end
end

return M
