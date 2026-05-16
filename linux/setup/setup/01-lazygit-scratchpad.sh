#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Setting up lazygit as pypr scratchpad..."

PYPR_CONF="${HOME}/.config/hypr/pyprland.conf"
KEYBIND_CONF="${HOME}/.config/hypr/keybindings.overrides.conf"
TERM_CLASS="pypr-lazygit"

if ! _cmd_present pypr; then
  warn "pyprland not installed — skipping lazygit scratchpad"
  return
fi

if ! _cmd_present lazygit; then
  warn "lazygit not installed — skipping scratchpad"
  return
fi

# pyprland.conf is managed by chezmoi.
log "lazygit pypr scratchpad is managed by chezmoi"

# Keybindings are managed by chezmoi.
log "lazygit keybinding is managed by chezmoi"

# Reload pypr
if pgrep -x pypr &>/dev/null; then
  pypr reload 2>/dev/null && success "pypr reloaded" || warn "pypr reload failed"
else
  pypr &>/dev/null &
  sleep 1
  log "pypr daemon started"
fi

success "Lazygit scratchpad ready (SUPER+Shift+L)"
