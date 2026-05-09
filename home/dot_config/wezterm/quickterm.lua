local wezterm = require "wezterm"
local act = wezterm.action

local M = {}

local state = { open = false, pane_id = nil }

function M.toggle(win, pane)
  local tab = win:active_tab()
  if not tab then return end
  local panes = tab:panes()

  if state.pane_id then
    local alive = false
    for _, p in ipairs(panes) do
      if p:pane_id() == state.pane_id then
        alive = true
        break
      end
    end
    if not alive then
      state = { open = false, pane_id = nil }
    end
  end

  if state.open then
    for _, p in ipairs(panes) do
      if p:pane_id() == state.pane_id then
        win:perform_action(act.CloseCurrentPane { confirm = false }, p)
        state = { open = false, pane_id = nil }
        return
      end
    end
  else
    win:perform_action(
      act.SplitVertical {
        domain = "CurrentPaneDomain",
        args = { "pwsh.exe", "-NoLogo", "-NoProfile", "-Command", [[
          & {
            $o = "`e[38;2;230;180;80m"
            $g = "`e[38;2;179;177;173m"
            $r = "`e[0m"
            Write-Host "${o}>${r} ${g}" -NoNewline
            $cmd = Read-Host
            if ($cmd) {
              $sw = [System.Diagnostics.Stopwatch]::StartNew()
              try { Invoke-Expression $cmd } catch { Write-Error $_ }
              $sw.Stop()
              if ($sw.ElapsedMilliseconds -ge 1500) {
                Write-Host "`n[Enter to close]"
                $null = Read-Host
              }
            }
          }
        ]] },
      }, pane)

    local new_tab = win:active_tab()
    if not new_tab then return end
    local bottom_pane = new_tab:active_pane()
    if not bottom_pane then return end

    state = { open = true, pane_id = bottom_pane:pane_id() }

    win:perform_action(act.ActivatePaneDirection "Up", bottom_pane)
    local top_pane = new_tab:active_pane()
    if top_pane then
      local rows = top_pane:get_dimensions().rows
      local shrink = math.floor(rows * 0.7)
      if shrink > 0 then
        win:perform_action(act.AdjustPaneSize { "Down", shrink }, top_pane)
      end
    end
    win:perform_action(act.ActivatePaneDirection "Down",
      new_tab:active_pane())
  end
end

return M
