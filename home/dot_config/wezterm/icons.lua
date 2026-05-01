local wezterm = require 'wezterm'

local M = {
  left_arrow = utf8.char(0xe0ba),
  left_most = utf8.char(0x2588),
  right_arrow = utf8.char(0xe0bc),
  admin = wezterm.nerdfonts.md_admin or utf8.char(0xf49c),
  cmd = wezterm.nerdfonts.md_console_line or utf8.char(0xe62a),
  nu = utf8.char(0xe7a8) or wezterm.nerdfonts.md_terminal,
  pwsh = wezterm.nerdfonts.md_powershell,
  elvish = utf8.char(0xfc6f) or wezterm.nerdfonts.md_terminal,
  wsl = wezterm.nerdfonts.md_linux or utf8.char(0xf83c),
  yori = utf8.char(0xf1d4) or wezterm.nerdfonts.md_console,
  nyagos = utf8.char(0xf61a) or wezterm.nerdfonts.md_terminal,
  vim = utf8.char(0xe62b) or wezterm.nerdfonts.custom_vim,
  pager = wezterm.nerdfonts.md_file_document or utf8.char(0xf718),
  fuzzy = wezterm.nerdfonts.md_magnifying_glass or utf8.char(0xf0b0),
  hourglass = wezterm.nerdfonts.md_timer_sand or utf8.char(0xf252),
  sunglasses = wezterm.nerdfonts.md_eye or utf8.char(0xf9df),
  python = wezterm.nerdfonts.md_language_python or utf8.char(0xf820),
  node = wezterm.nerdfonts.md_language_javascript or utf8.char(0xe74e),
  deno = wezterm.nerdfonts.md_language_typescript or utf8.char(0xe628),
  docker = wezterm.nerdfonts.md_docker or utf8.char(0xe7a1),
  ssh = wezterm.nerdfonts.md_ssh or utf8.char(0xf49e),
  git = wezterm.nerdfonts.md_git or utf8.char(0xe7a3),
  lambda = wezterm.nerdfonts.md_lambda or utf8.char(0xfb26),
  windows = wezterm.nerdfonts.md_windows or utf8.char(0xe70f),
}

return M
