local wezterm = require "wezterm"
local icons = require "icons"

local M = {}

local bells = {}

local function get_indicator(is_bell, is_unseen)
  local indicator = ''
  if is_bell then
    indicator = indicator .. ' 🔔'
  end
  if is_unseen then
    indicator = indicator .. ' ●'
  end
  return indicator
end

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

local function get_cwd_name(tab)
  local cwd = tab.active_pane.current_working_dir
  if cwd then
    local cwd_str = tostring(cwd)
    -- Normalize path separators and remove trailing slash
    cwd_str = cwd_str:gsub("/$", ""):gsub("\\$", "")
    -- Check if cwd is home directory (compare against USERPROFILE)
    local home = os.getenv("USERPROFILE") or os.getenv("HOME")
    if home then
      home = home:gsub("\\$", "")
      if cwd_str == home then
        return "~"
      end
    end
    return basename(cwd_str)
  end
  return nil
end

local function get_tab_title(tab, max_width)
  local pane_title = tab.active_pane.title
  local icon, process_name = get_process_name(tab)
  local cwd_name = get_cwd_name(tab)
  local title_with_icon = process_name and (icon .. ' ' .. process_name) or (tab.tab_title or tab.active_pane.title or '')
  if pane_title:match("^Administrator: ") then
    title_with_icon = title_with_icon .. " " .. icons.admin .. " "
  end

  title_with_icon = title_with_icon .. " " .. icons.folder .. " " .. (cwd_name or "")
  
  return title_with_icon
  --return " " .. wezterm.truncate_right(title_with_icon, max_width-6) .. " "
end

local subs = {'₁','₂','₃','₄','₅','₆','₇','₈','₉','₁₀'}
local sups = {'¹','²','³','⁴','⁵','⁶','⁷','⁸','⁹','¹⁰'}

M.setup = function(config, colors)
  config.enable_tab_bar = true
  config.use_fancy_tab_bar = false
  config.hide_tab_bar_if_only_one_tab = false
  config.tab_max_width = 70
  config.tab_and_split_indices_are_zero_based = false

  config.colors = {
    tab_bar = {
      background = colors.tab_bar_bg,
      new_tab = colors.new_tab,
      new_tab_hover = colors.new_tab_hover,
      active_tab = colors.active_tab,
      inactive_tab_edge = colors.inactive_tab_edge,
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
    local is_bell = bells[tab.tab_id]
    local is_unseen = has_unseen_output(tab)

    local tab_colors = {
      tab_fg = (hover and colors.tab_hover.fg_color) or (tab.is_active and colors.active_tab.fg_color or colors.inactive_tab.fg_color),
      tab_pane_idx_fg = (hover and colors.tab_hover.fg_color) or (tab.is_active and colors.active_tab.fg_color or colors.inactive_tab.fg_color),
      --bell = { bg_color = is_bell and colors.bell.bg_color or 'none', fg_color = is_bell and colors.bell.fg_color or 'none' },
      --unseen = { bg_color = is_unseen and colors.unseen.bg_color or 'none', fg_color = is_unseen and colors.unseen.fg_color or 'none' },

      -- Romboide like edges
      tab_bg = colors.active_tab.bg_color,
      right_edge_lower = 'none',
      right_edge_upper = colors.tab_edge,
      left_edge_lower = colors.tab_edge,
      left_edge_upper = 'none',
      left_edge_text = tab.tab_index == 0 and icons.left_most or icons.left_arrow,
      right_edge_text = icons.right_arrow,

      --No background colors
      -- tab_bg = 'none',
      -- right_edge_lower = 'none',
      -- right_edge_upper = 'none',
      -- left_edge_lower = 'none',
      -- left_edge_upper = 'none',
      -- left_edge_text = ' ',
      -- right_edge_text = ' ',
    }

    return {
      -- Left edge
      { Background = { Color = tab_colors.left_edge_upper } },
      { Foreground = { Color = tab_colors.left_edge_lower } },
      { Text = tab_colors.left_edge_text },
      -- Tab content
      { Background = { Color = tab_colors.tab_bg } }, 
      { Foreground = { Color = tab_colors.tab_fg } },
      -- Tab index and title
      { Text = subs[tab.tab_index + 1] or tostring(tab.tab_index + 1) },
      { Text = get_tab_title(tab, max_width) },
      { Foreground = { Color = tab_colors.tab_pane_idx_fg } },
      { Text = sups[tab.active_pane.pane_index + 1] or tostring(tab.active_pane.pane_index + 1) },
      --Bell
      --{ Background = { Color = tab_colors.bell.bg_color } }, 
      --{ Foreground = { Color = tab_colors.bell.fg_color } },
      { Text = is_bell and ' 🔔' or '' },
      --Unseen
      --{ Background = { Color = tab_colors.unseen.bg_color } }, 
     -- { Foreground = { Color = tab_colors.unseen.fg_color } },
      { Text = is_unseen and ' ●' or '' },
      -- Right edge
      { Background = { Color = tab_colors.right_edge_lower } }, 
      { Foreground = { Color = tab_colors.right_edge_upper } },
      { Text = tab_colors.right_edge_text },
    }
  end)
end

return M