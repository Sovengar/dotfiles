#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Ensuring AUR helpers (paru + yay) are installed..."

if ! command -v pacman &>/dev/null; then
  log "pacman not found, skipping AUR helpers"
  return
fi

_ensure_sudo
sudo pacman -S --noconfirm --needed git base-devel

# ── Install paru (primary AUR helper) ────────────────────────────
if ! _cmd_present paru; then
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT
  git clone https://aur.archlinux.org/paru-bin.git "$tmp_dir/paru-bin"
  (
    cd "$tmp_dir/paru-bin"
    makepkg -si --noconfirm
  )
  success "paru installed"
else
  log "paru already installed"
fi

# ── Install yay (secondary AUR helper) ──────────────────────────
if ! _cmd_present yay; then
  paru -S --noconfirm yay-bin
  success "yay installed"
else
  log "yay already installed"
fi
