#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Installing essential packages..."

detect_pkg_manager >/dev/null
_ensure_sudo

pkg_install git curl base-devel

# chezmoi
if _cmd_present chezmoi; then
  log "chezmoi already installed, running init --apply..."
  chezmoi init --apply https://github.com/Sovengar/dotfiles
else
  log "Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/Sovengar/dotfiles
fi

success "Essential packages installed"
