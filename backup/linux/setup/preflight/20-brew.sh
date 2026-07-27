#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Ensuring Linuxbrew is installed..."

if _cmd_present brew; then
  success "Homebrew already installed: $(brew --prefix)"
  eval "$(brew shellenv)"
  return
fi

log "Installing Linuxbrew..."
sudo pacman -S --noconfirm --needed base-devel procps-ng curl file git

NONINTERACTIVE=1 /bin/bash -c \
  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

success "Linuxbrew installed"
