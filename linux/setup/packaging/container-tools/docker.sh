#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Installing Docker..."

detect_pkg_manager >/dev/null
_ensure_sudo

if _cmd_present docker; then
  success "docker already installed"
  return
fi

case "$_pkg_manager" in
  apt)
    sudo apt install -y docker.io docker-buildx docker-compose-v2
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
    ;;
  pacman)
    sudo pacman -S --noconfirm docker docker-buildx docker-compose
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
    ;;
  dnf)
    sudo dnf install -y docker docker-buildx docker-compose
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
    ;;
  brew)
    brew install docker docker-buildx docker-compose
    ;;
esac

success "docker installed (log out and back in for group changes)"
