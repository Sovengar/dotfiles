# Wayland Misc all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../../helpers/all.sh"
fi

log "Installing misc Wayland packages..."

detect_pkg_manager >/dev/null
_ensure_sudo
pkg_install xdg-desktop-portal-hyprland hyprquery qt5-wayland qt6-wayland qt5ct qt6ct kvantum kvantum-qt5
success "Misc Wayland packages installed"
