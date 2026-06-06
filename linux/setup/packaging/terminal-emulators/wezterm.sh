#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

# wezterm-git descartado: PKGBUILD roto — pkgver() genera versiones que pacman
# ve como downgrade, conflicto con ncurses, y dependencias incorrectas (glib2, bash).
# nightly-bin descarga binarios precompilados de GitHub, sin compilar.
log "Installing wezterm (nightly bin)..."

if pacman -Q wezterm-nightly-bin &>/dev/null; then
  success "wezterm already installed (nightly)"
  return 0 2>/dev/null || exit 0
fi

aur_install wezterm-nightly-bin
success "wezterm installed"
