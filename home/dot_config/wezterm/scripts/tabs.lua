local icons = require "appearance.icons"
local fs = require "scripts.fs"

local M = {}

local TAB_TITLE_DIRECTORY_SECONDS = 8
local TAB_TITLE_PROCESS_SECONDS = 2

local shell_processes = {
  bash = true,
  cmd = true,
  elvish = true,
  fish = true,
  nu = true,
  nushell = true,
  nyagos = true,
  powershell = true,
  pwsh = true,
  wsl = true,
  wslhost = true,
  yori = true,
  zsh = true,
}

local process_titles = {
  btm = 'Btm',
  btop = 'Btop',
  docker = 'Docker',
  fzf = 'Fzf',
  htop = 'Htop',
  k9s = 'K9s',
  lazydocker = 'LazyDocker',
  lazygit = 'Lazygit',
  less = 'Less',
  nvim = 'Nvim',
  opencode = 'Opencode',
  ssh = 'Ssh',
  tmux = 'Tmux',
  vim = 'Vim',
  yazi = 'Yazi',
  zellij = 'Zellij',
}

local function capitalize(value)
  if not value or value == '' then return value end
  return value:sub(1, 1):upper() .. value:sub(2)
end

local function get_process_basename(tab)
  local prog = tab.active_pane.foreground_process_name or ''
  return fs.basename(prog):lower()
end

local function is_shell_process(process_name)
  return shell_processes[process_name] or false
end

local function format_process_title(process_name)
  if process_name == '' or is_shell_process(process_name) then return nil end
  return process_titles[process_name] or capitalize(process_name)
end

local function should_show_process_title(process_title)
  if not process_title then return false end

  local cycle_seconds = TAB_TITLE_DIRECTORY_SECONDS + TAB_TITLE_PROCESS_SECONDS
  return os.time() % cycle_seconds >= TAB_TITLE_DIRECTORY_SECONDS
end

function M.has_unseen_output(tab)
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
  elseif name:find('fish') then
    return icons.shell, 'Fish'
  elseif name:find('bash') then
    return icons.shell, 'Bash'
  elseif name:find('zsh') then
    return icons.shell, 'Zsh'
  elseif name:find('cmd') then
    return icons.cmd, 'Cmd'
  elseif name:find('wsl') or name:find('wslhost') or name:find('ubuntu') or name:find('debian') or name:find('fedora') then
    return icons.wsl, 'Wsl'
  elseif name:find('python') or name:find('hiss') then
    return icons.python, 'Py'
  elseif name:find('node') then
    return icons.node, 'Node'
  elseif name:find('opencode') then
    return icons.opencode, 'Opencode'
  elseif name:find('lazygit') then
    return icons.git, 'Lazygit'
  elseif name:find('lazydocker') then
    return icons.docker, 'LazyDocker'
  elseif name:find('docker') then
    return icons.docker, 'Dock'
  elseif name:find('yazi') then
    return icons.folder, 'Yazi'
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

local function get_cwd_name(tab, full)
  local cwd = tab.active_pane.current_working_dir
  if cwd then
    local cwd_str = fs.normalize_path(cwd)
    local home = fs.normalize_path(os.getenv("USERPROFILE") or os.getenv("HOME"))

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
    return fs.basename(cwd_str)
  end
  return nil
end

function M.get_tab_title(tab, _max_width, hover)
  local pane_title = tab.active_pane.title

  -- if tab.title and tab.title ~= '' and tab.title ~= pane_title then
  --   return tab.title
  -- end

  local icon, _process_name = get_process_name(tab)
  local cwd_name = capitalize(get_cwd_name(tab, hover))
  local process_title = format_process_title(get_process_basename(tab))
  local show_process_title = should_show_process_title(process_title)
  local visible_title = show_process_title and process_title or cwd_name

  -- local title = icons.folder .. " " .. (visible_title or "")
  local title = visible_title or ""
  title = title .. (show_process_title and (" " .. (icon or "")) or "") .. " "

  if pane_title:match("^Administrator: ") then
    title = title .. " " .. icons.admin
  end

  return title
end

function M.get_hover_state(hover, max_width)
  if type(hover) == 'number' then
    return max_width
  end
  return hover
end

function M.get_state(tab, is_hover)
  if is_hover then return "hover" end
  if tab.is_active then return "active" end
  return "inactive"
end

function M.get_tab_colors(tab, theme, state, is_hover)
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

  return {
    tab_fg = tab_fg,
    tab_bg = tab_bg,
    tab_pane_idx_fg = tab_fg,
    bell = theme[state .. "_bell"] or { bg_color = "none", fg_color = "none" },
    unseen = theme[state .. "_unseen"] or { bg_color = "none", fg_color = "none" },
    right_edge_lower = theme[state .. "_right_edge_lower"],
    right_edge_upper = theme[state .. "_right_edge_upper"],
    left_edge_lower = theme[state .. "_left_edge_lower"],
    left_edge_upper = theme[state .. "_left_edge_upper"],
    left_edge_text = tab.tab_index == 0 and theme.tab_style.left_most or theme.tab_style.left_arrow,
    right_edge_text = theme.tab_style.right_arrow,
  }
end

return M
