#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

HYDE_REPO="${HYDE_REPO:-$HOME/dev/projects/HyDE}"

log "Installing HyDE fonts..."

# ── System package fonts ──────────────────────────────────────

log "Installing system font packages..."

detect_pkg_manager >/dev/null
case "$_pkg_manager" in
  pacman)
    _ensure_sudo
    pkg_install noto-fonts-emoji cantarell-fonts noto-fonts-cjk
    ;;
  apt)
    _ensure_sudo
    pkg_install fonts-noto-color-emoji fonts-cantarell fonts-noto-cjk
    ;;
  dnf)
    _ensure_sudo
    pkg_install google-noto-emoji-fonts cantarell-fonts google-noto-cjk-fonts
    ;;
  brew)
    pkg_install font-noto-color-emoji font-cantarell font-noto-sans-cjk
    ;;
esac

# ── Nerd Fonts from GitHub releases ───────────────────────────

install_nerd_font() {
  local name="$1"
  local font_family="$2"
  local target_dir="$HOME/.local/share/fonts/${name}NerdFont"

  if fc-match "$font_family" 2>/dev/null | grep -qi "${font_family%% *}"; then
    success "$font_family already installed"
    return
  fi

  log "Downloading $font_family..."
  mkdir -p "$target_dir"
  local tmp_zip="/tmp/${name}.zip"
  curl -fsL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${name}.zip" -o "$tmp_zip"
  unzip -o "$tmp_zip" -d "$target_dir" >/dev/null
  rm -f "$tmp_zip"
  fc-cache -f "$target_dir"
  success "$font_family installed"
}

install_nerd_font "CascadiaCode" "CaskaydiaCove Nerd Font"
install_nerd_font "Mononoki" "Mononoki Nerd Font"
install_nerd_font "MapleMono" "Maple Mono Nerd Font"

# ── Material Design Icons (from HyDE tarball or direct download) ──

if ! fc-match "Material Design Icons" 2>/dev/null | grep -qi "Material Design"; then
  log "Installing Material Design Icons..."
  mkdir -p "$HOME/.local/share/fonts/material-design-icons"
  local tmp_zip="/tmp/MaterialDesign-Webfont.zip"
  curl -fsL "https://github.com/Templarian/MaterialDesign-Webfont/archive/refs/heads/master.zip" -o "$tmp_zip"
  unzip -o "$tmp_zip" "MaterialDesign-Webfont-master/fonts/*" -d "/tmp/md-extract" >/dev/null
  cp /tmp/md-extract/MaterialDesign-Webfont-master/fonts/*.ttf "$HOME/.local/share/fonts/material-design-icons/" 2>/dev/null || true
  rm -rf "$tmp_zip" "/tmp/md-extract"
  fc-cache -f "$HOME/.local/share/fonts/material-design-icons"
  success "Material Design Icons installed"
else
  success "Material Design Icons already installed"
fi

# ── Hyprlock fonts (downloaded on-demand by HyDE, we pre-install them) ──

install_url_font() {
  local name="$1"
  local url="$2"
  local font_family="$3"

  if fc-match "$font_family" 2>/dev/null | grep -qi "${font_family%% *}"; then
    success "$font_family already installed"
    return
  fi

  log "Downloading $font_family..."
  local target_dir="$HOME/.local/share/fonts/hyde"
  mkdir -p "$target_dir"
  local tmp_zip="/tmp/hyde-${name}.zip"
  curl -fsL "$url" -o "$tmp_zip"
  unzip -o "$tmp_zip" -d "$target_dir" >/dev/null 2>&1 || {
    warn "Failed to extract $font_family from zip, trying direct download"
    rm -f "$tmp_zip"
    return
  }
  rm -f "$tmp_zip"
  find "$target_dir" -name "*.ttf" -o -name "*.otf" | xargs -I{} mv {} "$target_dir"/ 2>/dev/null || true
  fc-cache -f "$target_dir"
  success "$font_family installed"
}

install_url_font "Inter" "https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip" "Inter"
install_url_font "IBMPlexSans" "https://github.com/IBM/plex/releases/download/v6.4.0/ibm-plex-sans.zip" "IBM Plex Sans"
install_url_font "SFProDisplay" "https://font.download/dl/font/sf-pro-display.zip" "SF Pro Display"
install_url_font "Anurati" "https://font.download/dl/font/anurati.zip" "Anurati"
install_url_font "AlfaSlabOne" "https://font.download/dl/font/alfa-slab-one.zip" "Alfa Slab One"

success "All HyDE fonts installed"
