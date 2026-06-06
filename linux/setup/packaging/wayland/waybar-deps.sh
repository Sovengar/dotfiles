#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing Waybar dependencies..."

detect_pkg_manager >/dev/null
_ensure_sudo

case "$_pkg_manager" in
  pacman)
    pkg_install \
      waybar rofi jq libnotify iproute2 \
      networkmanager network-manager-applet \
      pipewire pipewire-pulse wireplumber pavucontrol pamixer \
      python-gobject \
      playerctl gamemode lm_sensors udiskie blueman \
      power-profiles-daemon brightnessctl swaync hyprsunset \
      cliphist wl-clipboard dunst
    aur_install zscroll-git
    ;;
  apt)
    pkg_install \
      waybar rofi jq libnotify-bin iproute2 \
      network-manager network-manager-gnome \
      pipewire pipewire-pulse wireplumber pavucontrol pamixer \
      python3-gi gir1.2-playerctl-2.0 \
      playerctl gamemode lm-sensors udiskie blueman \
      power-profiles-daemon brightnessctl wl-clipboard dunst
    warn "Some Hyprland ecosystem packages may need manual/AUR-equivalent install on apt: swaync, hyprsunset, cliphist"
    warn "zscroll may need manual installation on apt"
    ;;
  dnf)
    pkg_install \
      waybar rofi jq libnotify iproute \
      NetworkManager NetworkManager-applet \
      pipewire pipewire-pulseaudio wireplumber pavucontrol pamixer \
      python3-gobject playerctl-libs \
      playerctl gamemode lm_sensors udiskie blueman \
      power-profiles-daemon brightnessctl wl-clipboard dunst
    warn "Some Hyprland ecosystem packages may need COPR/manual install on dnf: swaync, hyprsunset, cliphist"
    warn "zscroll may need manual installation on dnf"
    ;;
  brew)
    pkg_install waybar rofi jq libnotify iproute2 playerctl
    warn "Linux desktop services such as NetworkManager, PipeWire, udiskie, blueman and Hyprland helpers are not fully managed by Homebrew"
    ;;
esac

success "Waybar dependencies installed"
