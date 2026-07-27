# winapps-vm dependency installer
# Installs all Linux packages needed to run the Windows VM

#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing winapps-vm dependencies..."

# RDP client
pkg_install freerdp

# Network utilities for port checking
pkg_install openbsd-netcat

# Interactive prompts (used by winapps-vm install)
pkg_install gum

# Notifications
pkg_install libnotify

# URL handling
pkg_install xdg-utils

# JSON parsing (Hyprland scale detection)
pkg_install jq

# Docker and Docker Compose (covered by container-tools/docker.sh, but check)
if _cmd_missing docker; then
  warn "Docker is not installed. Install it with: linux/setup/packaging/container-tools/docker.sh"
fi

if _cmd_missing docker-compose; then
  warn "Docker Compose is not installed. It should come with Docker."
fi

success "winapps-vm dependencies installed"