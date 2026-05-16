#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Configuring pyprland..."

if ! _cmd_present pypr; then
  warn "pyprland not installed — skipping config"
  return
fi

# pyprland.conf is managed by chezmoi at home/dot_config/hypr/pyprland.conf.
# Do not mutate it here; setup scripts should only install/enable services.
PYPR_CONFIG="$HOME/.config/hypr/pyprland.conf"
if [[ ! -f "$PYPR_CONFIG" ]]; then
  warn "pyprland.conf not found; it should be applied by chezmoi"
else
  log "pyprland config present"
fi

# Add exec-once to Hyprland config
HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"
if [[ -f "$HYPR_CONFIG" ]]; then
  if ! grep -q "exec-once.*pypr" "$HYPR_CONFIG" 2>/dev/null; then
    echo "exec-once = pypr" >> "$HYPR_CONFIG"
    success "Added pypr autostart to $HYPR_CONFIG"
  else
    log "pypr autostart already configured"
  fi
else
  log "Hyprland config not found — add 'exec-once = pypr' manually"
fi

success "pyprland configured"
