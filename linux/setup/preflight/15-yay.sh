#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Ensuring yay is installed..."

if _cmd_present yay; then
  success "yay already installed"
  return
fi

if ! command -v pacman &>/dev/null; then
  log "pacman not found, skipping yay"
  return
fi

_ensure_sudo
sudo pacman -S --noconfirm --needed git base-devel

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

git clone https://aur.archlinux.org/yay-bin.git "$tmp_dir/yay-bin"
(
  cd "$tmp_dir/yay-bin"
  makepkg -si --noconfirm
)

success "yay installed"
