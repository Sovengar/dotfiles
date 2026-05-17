#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing Handy..."

if _cmd_present handy || _cmd_present Handy; then
  success "Handy already installed"
  return
fi

detect_pkg_manager >/dev/null

arch="$(uname -m)"
case "$arch" in
  x86_64|amd64)
    deb_arch="amd64"
    rpm_arch="x86_64"
    appimage_arch="amd64"
    ;;
  aarch64|arm64)
    deb_arch="arm64"
    rpm_arch="aarch64"
    appimage_arch="aarch64"
    ;;
  *)
    err "Unsupported architecture for Handy: $arch"
    exit 1
    ;;
esac

tag="$(curl -fsL https://api.github.com/repos/cjpais/Handy/releases/latest | grep '"tag_name"' | cut -d'"' -f4)"
version="${tag#v}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

case "$_pkg_manager" in
  apt)
    _ensure_sudo
    asset="$tmp_dir/Handy_${version}_${deb_arch}.deb"
    curl -fsL "https://github.com/cjpais/Handy/releases/download/$tag/Handy_${version}_${deb_arch}.deb" -o "$asset"
    sudo apt install -y "$asset"
    ;;
  dnf)
    _ensure_sudo
    asset="$tmp_dir/Handy-${version}-1.${rpm_arch}.rpm"
    curl -fsL "https://github.com/cjpais/Handy/releases/download/$tag/Handy-${version}-1.${rpm_arch}.rpm" -o "$asset"
    sudo dnf install -y "$asset"
    ;;
  pacman)
    aur_install handy-bin
    ;;
  brew)
    mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
    asset="$HOME/.local/bin/Handy.AppImage"
    curl -fsL "https://github.com/cjpais/Handy/releases/download/$tag/Handy_${version}_${appimage_arch}.AppImage" -o "$asset"
    chmod +x "$asset"
    ln -sf "$asset" "$HOME/.local/bin/handy"
    ;;
esac

success "Handy installed"
