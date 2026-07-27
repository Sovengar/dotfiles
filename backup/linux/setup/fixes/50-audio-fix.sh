#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Applying audio fix for ALC897..."

if ! _cmd_present amixer; then
  warn "amixer not found — skipping audio fix"
  return
fi

# Disable Auto-Mute Mode (rear line-out silenced when front jack detected)
amixer -c 0 sset 'Auto-Mute Mode' Disabled 2>/dev/null || true

# Unmute and set Front channel
amixer -c 0 sset Front unmute 2>/dev/null || true
amixer -c 0 sset Front 80% 2>/dev/null || true

# Save ALSA state
sudo alsactl store 2>/dev/null || true

# Set default PulseAudio/WirePlumber sink
if _cmd_present pactl; then
  SINK=$(pactl list short sinks 2>/dev/null | grep -i "analog" | head -1 | awk '{print $2}' || true)
  if [[ -n "$SINK" ]]; then
    pactl set-default-sink "$SINK" 2>/dev/null || true
    success "Default sink set to $SINK"
  fi
fi

success "Audio fix applied"
