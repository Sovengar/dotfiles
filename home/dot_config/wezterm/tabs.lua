local wezterm = require "wezterm"
local icons = require "icons"

local M = {}

local bells = {}

local function has_unseen_output(tab)
  if tab.is_active then
    return false
  end
  for _, pane in ipairs(tab.panes) do
    if pane.has_unseen_output then
      return true
    end
  end
  return false
end

local function get_process_name(tab)
  local prog = tab.active_pane.foreground_process_name or ''
  local name = prog:lower()
  local pane_title = tab.active_pane.title

  if name:find('pwsh') or name:find('powershell') then
    return icons.pwsh, 'Pwsh'
  elseif name:find('cmd') then
    return icons.cmd, 'Cmd'
  elseif name:find('wsl') or name:find('wslhost') or name:find('ubuntu') or name:find('debian') or name:find('fedora') then
    return icons.wsl, 'Wsl'
  elseif name:find('python') or name:find('hiss')then
    return icons.python, 'Py'
  elseif name:find('node') then
    return icons.node, 'Node'
  elseif name:find('docker') then
    return icons.docker, 'Dock'
  elseif name:find('ssh') then
    return icons.ssh, 'Ssh'
  elseif name:find('git') then
    return icons.git, 'Git'
  elseif name:find('vim') or name:find('nvim') then
    return icons.vim, pane_title:gsub("^(%S+)%s+(%d+/%d+) %- nvim", " %2 %1")
  elseif name:find('fzf') or name:find('hs') or name:find('peco') then
    return icons.fuzzy, prog:upper()
  elseif name:find('deno') then
    return icons.deno, 'Deno'
  elseif name:find('yori') then
    return icons.yori, pane_title:gsub(" %- Yori", "")
  elseif name:find('nu') or name:find('nushell') then
    return icons.nu, 'Nu'
  elseif name:find('elvish') then
    return icons.elvish, 'Elvish'
  elseif name:find('btm') or name:find('ntop') then
    return icons.sunglasses, prog:upper()
  elseif name:find('nyagos') then
    return icons.nyagos, pane_title:gsub(".*: (.+) %- .+", "%1")
  elseif name:find('bat') or name:find('less') or name:find('moar') then
    return icons.pager, prog:upper()
  elseif name:find('bb') or name:find('cmd%-clj') or name:find('janet') or name:find('hy') then
    return icons.fuzzy, prog:gsub("bb", "Babashka"):gsub("cmd%-clj", "Clojure")
  else
    return icons.hourglass, prog:sub(1, 3)
  end

  return nil, nil
end

local function basename(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local function normalize_path(path)
  if not path then return nil end
  -- Convert to string and handle URL format (file:///C:/Users/buble)
  local s = tostring(path)
  s = s:gsub("^file://", "")
  -- Normalize separators to forward slashes
  s = s:gsub("\\", "/")
  -- Remove leading slash (e.g., /C:/Users/buble -> C:/Users/buble)
  s = s:gsub("^/", "")
  -- Remove trailing slash
  s = s:gsub("/$", "")
  return s
end

local function get_cwd_name(tab, full)
  local cwd = tab.active_pane.current_working_dir
  if cwd then
    local cwd_str = normalize_path(cwd)
    local home = normalize_path(os.getenv("USERPROFILE") or os.getenv("HOME"))
    
    if cwd_str and home then
      if cwd_str:lower() == home:lower() then
        return "~"
      end
      if full then
        if cwd_str:lower():find(home:lower(), 1, true) == 1 then
          return "~" .. cwd_str:sub(#home + 1)
        end
        return cwd_str
      end
    end
    return basename(cwd_str)
  end
  return nil
end

local function get_tab_title(tab, _max_width, hover)
  local pane_title = tab.active_pane.title
  local icon, _process_name = get_process_name(tab)
  local cwd_name = get_cwd_name(tab, hover)
  
  local title = icons.folder .. " " .. (cwd_name or "")
  title = title .. " " .. (icon or "") .. " "
  
  if pane_title:match("^Administrator: ") then
    title = title .. " " .. icons.admin
  end
  
  return title
end

local subs = {'₁','₂','₃','₄','₅','₆','₇','₈','₉','₁₀'}
local sups = {'¹','²','³','⁴','⁵','⁶','⁷','⁸','⁹','¹⁰'}

M.setup = function(config, theme)
  config.enable_tab_bar = true
  config.use_fancy_tab_bar = false
  config.hide_tab_bar_if_only_one_tab = false
  config.tab_max_width = 70
  config.tab_and_split_indices_are_zero_based = false

  config.colors = {
    tab_bar = {
      background = theme.tab_bar_bg,
      new_tab = theme.new_tab,
      new_tab_hover = theme.new_tab_hover,
    }
  }

  config.audible_bell = 'Disabled'
  config.visual_bell = {
    fade_in_duration_ms = 75,
    fade_out_duration_ms = 75,
    target = "CursorColor",
  }

  wezterm.on('bell', function(window, pane)
    local active_tab = window:active_tab()
    local bell_tab = pane:tab()
    if active_tab ~= bell_tab then
      bells[bell_tab.tab_id] = true
    end
  end)

  wezterm.on('format-tab-title', function(tab, tabs, panes, conf, hover, max_width)
    local is_hover = hover
    if type(hover) == 'number' then
      is_hover = max_width
    end

    local is_bell = bells[tab.tab_id]
    local is_unseen = has_unseen_output(tab)

    local state = "inactive"
    if tab.is_active then state = "active" end
    if is_hover then state = "hover" end

    local bell_color = theme[state .. "_bell"] or { bg_color = "none", fg_color = "none" }
    local unseen_color = theme[state .. "_unseen"] or { bg_color = "none", fg_color = "none" }

    local tab_fg, tab_bg
    if is_hover then
      tab_fg = theme.tab_hover.fg_color
      tab_bg = theme.tab_hover.bg_color
    elseif tab.is_active then
      tab_fg = theme.active_tab.fg_color
      tab_bg = theme.active_tab.bg_color
    else
      tab_fg = theme.inactive_tab.fg_color
      tab_bg = theme.inactive_tab.bg_color
    end

    local tab_colors = {
      tab_fg = tab_fg,
      tab_bg = tab_bg,
      tab_pane_idx_fg = tab_fg,
      bell = bell_color,
      unseen = unseen_color,
      right_edge_lower = theme[state .. "_right_edge_lower"],
      right_edge_upper = theme[state .. "_right_edge_upper"],
      left_edge_lower = theme[state .. "_left_edge_lower"],
      left_edge_upper = theme[state .. "_left_edge_upper"],
      left_edge_text = tab.tab_index == 0 and theme.tab_style.left_most or theme.tab_style.left_arrow,
      right_edge_text = theme.tab_style.right_arrow,
    }

    return {
      -- Left edge
      { Background = { Color = tab_colors.left_edge_upper } },
      { Foreground = { Color = tab_colors.left_edge_lower } },
      { Text = tab_colors.left_edge_text },
      -- Tab suffixes
      { Background = { Color = tab_colors.tab_bg } }, 
      { Foreground = { Color = tab_colors.tab_fg } },
      { Text = subs[tab.tab_index + 1] or tostring(tab.tab_index + 1) },
      { Foreground = { Color = tab_colors.tab_pane_idx_fg } },
      { Text = sups[tab.active_pane.pane_index + 1] or tostring(tab.active_pane.pane_index + 1) },
      -- Tab title
      { Foreground = { Color = tab_colors.tab_fg } },
      { Text = get_tab_title(tab, max_width, is_hover) },
      -- Bell icon
      { Background = { Color = is_bell and tab_colors.bell.bg_color or tab_colors.tab_bg } }, 
      { Foreground = { Color = is_bell and tab_colors.bell.fg_color or tab_colors.tab_fg } },
      { Text = is_bell and ' 🔔' or '' },
      -- Unseen icon
      { Background = { Color = is_unseen and tab_colors.unseen.bg_color or tab_colors.tab_bg } }, 
      { Foreground = { Color = is_unseen and tab_colors.unseen.fg_color or tab_colors.tab_fg } },
      { Text = is_unseen and ' ●' or '' },
      -- Right edge
      { Background = { Color = tab_colors.right_edge_lower } }, 
      { Foreground = { Color = tab_colors.right_edge_upper } },
      { Text = tab_colors.right_edge_text },
    }
  end)
end

return M