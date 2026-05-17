#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing audio stack..."

if pkg_is_installed pipewire && pkg_is_installed wireplumber; then
  success "Audio stack already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo

  case "$_pkg_manager" in
    pacman)
      pkg_install pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse gst-plugin-pipewire wireplumber pavucontrol pamixer
      ;;
    apt)
      pkg_install pipewire pipewire-audio pipewire-pulse wireplumber gstreamer1.0-pipewire pavucontrol pamixer
      ;;
    dnf)
      pkg_install pipewire pipewire-alsa pipewire-jack-audio-connection-kit pipewire-pulseaudio wireplumber pavucontrol pamixer
      ;;
    brew)
      pkg_install pipewire pavucontrol pamixer
      ;;
  esac

  success "Audio stack installed"
fi
