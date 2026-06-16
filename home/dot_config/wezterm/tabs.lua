local wezterm = require "wezterm"
local tab_scripts = require "scripts.tabs"

local M = {}

local USE_ROMBOS = false
local bells = {}
local subs = {'₁','₂','₃','₄','₅','₆','₇','₈','₉','₁₀'}
local sups = {'¹','²','³','⁴','⁵','⁶','⁷','⁸','⁹','¹⁰'}

local function format_tab_title(tab, theme, hover, max_width)
  local is_hover = tab_scripts.get_hover_state(hover, max_width)
  local is_bell = bells[tab.tab_id]
  local is_unseen = tab_scripts.has_unseen_output(tab)
  local state = tab_scripts.get_state(tab, is_hover)
  local tab_colors = tab_scripts.get_tab_colors(tab, theme, state, is_hover)

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
    { Text = tab_scripts.get_tab_title(tab, max_width, is_hover) },
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
end

M.setup = function(config, theme)
  local tab_theme = theme.get_tab_theme(USE_ROMBOS)

  config.enable_tab_bar = true
  config.use_fancy_tab_bar = true
  config.hide_tab_bar_if_only_one_tab = true
  config.show_close_tab_button_in_tabs = false
  config.show_new_tab_button_in_tab_bar = false
  config.tab_max_width = 18
  config.tab_and_split_indices_are_zero_based = false

  -- WezTerm styles the fancy tab bar through window_frame.
  config.window_frame = config.window_frame or {}
  config.window_frame.font_size = 12
  config.window_frame.active_titlebar_bg = "transparent"
  config.window_frame.inactive_titlebar_bg = "transparent"
  config.window_frame.active_titlebar_border_bottom = "transparent"
  config.window_frame.inactive_titlebar_border_bottom = "transparent"
  config.window_frame.button_bg = "transparent"
  config.window_frame.button_hover_bg = "transparent"

  config.colors = {
    tab_bar = {
      background = tab_theme.tab_bar_bg,
      new_tab = tab_theme.new_tab,
      new_tab_hover = tab_theme.new_tab_hover,
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

  wezterm.on('format-tab-title', function(tab, _tabs, _panes, _conf, hover, max_width)
    return format_tab_title(tab, tab_theme, hover, max_width)
  end)
end

return M
