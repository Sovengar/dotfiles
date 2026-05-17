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
DESKTOP_ENTRY="${HOME}/.local/share/applications/lazygit.desktop"
LAUNCHER="${HOME}/.local/bin/pypr-lazygit-cwd"

if ! _cmd_present pypr; then
  warn "pyprland not installed — skipping lazygit scratchpad"
  return
fi

if ! _cmd_present lazygit; then
  warn "lazygit not installed — skipping scratchpad"
  return
fi

mkdir -p "$(dirname "$DESKTOP_ENTRY")" "$(dirname "$LAUNCHER")"

cat > "$LAUNCHER" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

cwd="$HOME"
fallback_repo="$HOME/.local/share/chezmoi"
pid="$(hyprctl activewindow -j 2>/dev/null | jq -r '.pid // empty' 2>/dev/null || true)"

if [[ -n "$pid" && -r "/proc/$pid/cwd" ]]; then
  current="$pid"
  while true; do
    mapfile -t children < <(pgrep -P "$current" 2>/dev/null || true)
    ((${#children[@]} == 0)) && break
    current="${children[-1]}"
  done

  if [[ -r "/proc/$current/cwd" ]]; then
    cwd="$(readlink "/proc/$current/cwd" 2>/dev/null || printf '%s' "$HOME")"
  fi
fi

if git_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)"; then
  cwd="$git_root"
elif [[ -d "$fallback_repo/.git" ]]; then
  cwd="$fallback_repo"
fi

exec kitty --class pypr-lazygit --working-directory "$cwd" -e lazygit -p "$cwd"
EOF
chmod +x "$LAUNCHER"
success "lazygit pypr launcher configured"

cat > "$DESKTOP_ENTRY" <<'EOF'
[Desktop Entry]
Version=1.0
Name=lazygit
Comment=Git TUI
Exec=pypr toggle lazygit
Terminal=false
Type=Application
Icon=git
StartupNotify=true
EOF
chmod +x "$DESKTOP_ENTRY"
update-desktop-database "${HOME}/.local/share/applications/" 2>/dev/null || true
success "lazygit rofi entry configured"

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

success "Lazygit scratchpad ready (SUPER+G)"
