#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing icon themes..."

ICON_DIR="${HOME}/.local/share/icons"

TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

mkdir -p "$ICON_DIR"

install_aur_pkg() {
  local pkg="$1"
  if pacman -Qi "$pkg" &>/dev/null; then
    info "$pkg already installed"
  else
    log "Installing $pkg..."
    if command -v paru &>/dev/null; then
      paru -S --noconfirm "$pkg" 2>&1 || warn "paru failed for $pkg"
    else
      warn "paru not found, skipping $pkg"
    fi
  fi
}

# --- candy-icons (from Paranoid-Sweet repo) ---
ICON_CANDY_TARGET="${ICON_DIR}/candy-icons"
if [[ ! -d "$ICON_CANDY_TARGET" ]]; then
  log "  Downloading candy-icons..."
  curl -fsSL "https://github.com/rishav12s/Paranoid-Sweet/archive/303ec22d4d1276a636466f61eb71be28a1ef2a85.tar.gz" \
    -o "$TMP_DIR/paranoid-sweet.tar.gz"
  PARANOID_SRC="${TMP_DIR}/paranoid"
  mkdir -p "$PARANOID_SRC"
  tar -xzf "$TMP_DIR/paranoid-sweet.tar.gz" -C "$PARANOID_SRC" --strip-components=1
  tar -xzf "$PARANOID_SRC/Source/arcs/Icon_Candy.tar.gz" -C "$ICON_DIR"
  gtk-update-icon-cache -f "$ICON_CANDY_TARGET" 2>/dev/null || true
  success "  candy-icons installed"
else
  info "  candy-icons already installed"
fi

# --- Tela-circle-pink (from Oxo-Carbon repo) ---
ICON_TELA_TARGET="${ICON_DIR}/Tela-circle-pink"
if [[ ! -d "$ICON_TELA_TARGET" ]]; then
  log "  Downloading Tela-circle-pink..."
  curl -fsSL "https://github.com/rishav12s/Oxo-Carbon/archive/refs/heads/Oxo-Carbon.tar.gz" \
    -o "$TMP_DIR/oxo-carbon.tar.gz"
  OXO_SRC="${TMP_DIR}/oxo"
  mkdir -p "$OXO_SRC"
  tar -xzf "$TMP_DIR/oxo-carbon.tar.gz" -C "$OXO_SRC" --strip-components=1
  tar -xzf "$OXO_SRC/Source/arcs/Icon_Tela-circle-pink.tar.gz" -C "$ICON_DIR"
  ln -sfn "$ICON_TELA_TARGET" "${HOME}/.icons/Tela-circle-pink"
  gtk-update-icon-cache -f -q "$ICON_TELA_TARGET" 2>/dev/null || true
  success "  Tela-circle-pink installed"
else
  info "  Tela-circle-pink already installed"
fi

# --- pixel-dream icons ---
ICON_PIXEL_TARGET="${HOME}/.icons/pixel-dream"
if [[ ! -d "$ICON_PIXEL_TARGET" ]]; then
  log "  Downloading pixel-dream icons..."
  curl -fsSL "https://github.com/rishav12s/Pixel-Dream/archive/79607bbf37c356acb80992c8302ada3336f9d8fa.tar.gz" \
    -o "$TMP_DIR/pixel-dream.tar.gz"
  PD_SRC="${TMP_DIR}/pixel-dream"
  mkdir -p "$PD_SRC"
  tar -xzf "$TMP_DIR/pixel-dream.tar.gz" -C "$PD_SRC" --strip-components=1
  tar -xzf "$PD_SRC/Source/arcs/Icon_pixel-dream.tar.gz" -C "${HOME}/.icons"
  success "  pixel-dream icons installed"
else
  info "  pixel-dream icons already installed"
fi

# --- Tela-circle-black (from Vanta-Black repo) ---
ICON_VB_TARGET="${ICON_DIR}/Tela-circle-black"
if [[ ! -d "$ICON_VB_TARGET" ]]; then
  log "  Downloading Tela-circle-black (Vanta-Black)..."
  if [[ ! -f "$TMP_DIR/vanta-black.tar.gz" ]]; then
    curl -fsSL "https://github.com/rishav12s/Vanta-Black/archive/refs/heads/Vanta-Black.tar.gz" \
      -o "$TMP_DIR/vanta-black.tar.gz"
    VB_SRC="${TMP_DIR}/vanta"
    mkdir -p "$VB_SRC"
    tar -xzf "$TMP_DIR/vanta-black.tar.gz" -C "$VB_SRC" --strip-components=1
  fi
  tar -xzf "$VB_SRC/Source/arcs/Icon_Tela-circle-black.tar.gz" -C "$ICON_DIR"
  ln -sfn "$ICON_VB_TARGET" "${HOME}/.icons/Tela-circle-black"
  gtk-update-icon-cache -f -q "$ICON_VB_TARGET" 2>/dev/null || true
  success "  Tela-circle-black installed"
else
  info "  Tela-circle-black already installed"
fi

# --- Rain-Dark icons (from Rain-Dark repo) ---
ICON_RD_TARGET="${ICON_DIR}/Rain-Dark"
if [[ ! -d "$ICON_RD_TARGET" ]]; then
  log "  Downloading Rain-Dark icons..."
  if [[ ! -f "$TMP_DIR/rain-dark.tar.gz" ]]; then
    curl -fsSL "https://github.com/rishav12s/Rain-Dark/archive/refs/heads/Rain-Dark.tar.gz" \
      -o "$TMP_DIR/rain-dark.tar.gz"
    RD_SRC="${TMP_DIR}/rain"
    mkdir -p "$RD_SRC"
    tar -xzf "$TMP_DIR/rain-dark.tar.gz" -C "$RD_SRC" --strip-components=1
  fi
  tar -xzf "$RD_SRC/Source/arcs/Icon_Rain-Dark.tar.gz" -C "$ICON_DIR"
  ln -sfn "$ICON_RD_TARGET" "${HOME}/.icons/Rain-Dark"
  gtk-update-icon-cache -f -q "$ICON_RD_TARGET" 2>/dev/null || true
  success "  Rain-Dark icons installed"
else
  info "  Rain-Dark icons already installed"
fi

# --- Colorful-Dark-Icons (from Crimson-Blade repo) ---
ICON_CRIMSON_TARGET="${ICON_DIR}/Colorful-Dark-Icons"
if [[ ! -d "$ICON_CRIMSON_TARGET" ]]; then
  log "  Downloading Colorful-Dark-Icons..."
  if [[ ! -f "$TMP_DIR/crimson-blade.tar.gz" ]]; then
    curl -fsSL "https://github.com/cyb3rgh0u1/Crimson-Blade/archive/refs/heads/main.tar.gz" \
      -o "$TMP_DIR/crimson-blade.tar.gz"
    CB_SRC="${TMP_DIR}/crimson"
    mkdir -p "$CB_SRC"
    tar -xzf "$TMP_DIR/crimson-blade.tar.gz" -C "$CB_SRC" --strip-components=1
  fi
  tar -xzf "$CB_SRC/Source/arcs/Icon_Dark_Beam.tar.gz" -C "$ICON_DIR"
  ln -sfn "$ICON_CRIMSON_TARGET" "${HOME}/.icons/Colorful-Dark-Icons"
  gtk-update-icon-cache -f -q "$ICON_CRIMSON_TARGET" 2>/dev/null || true
  success "  Colorful-Dark-Icons installed"
else
  info "  Colorful-Dark-Icons already installed"
fi

# --- Tela-circle-hotred (from Scarlet-Night repo) ---
ICON_SCARLET_TARGET="${ICON_DIR}/Tela-circle-hotred"
if [[ ! -d "$ICON_SCARLET_TARGET" ]]; then
  log "  Downloading Tela-circle-hotred (Scarlet-Night)..."
  if [[ ! -f "$TMP_DIR/scarlet-night.tar.gz" ]]; then
    curl -fsSL "https://github.com/abenezerw/Scarlet-Night/archive/refs/heads/main.tar.gz" \
      -o "$TMP_DIR/scarlet-night.tar.gz"
    SN_SRC="${TMP_DIR}/scarlet"
    mkdir -p "$SN_SRC"
    tar -xzf "$TMP_DIR/scarlet-night.tar.gz" -C "$SN_SRC" --strip-components=1
  fi
  tar -xzf "$SN_SRC/Source/arcs/Icon_Tela-circle-hotred.tar.gz" -C "$ICON_DIR"
  ln -sfn "$ICON_SCARLET_TARGET" "${HOME}/.icons/Tela-circle-hotred"
  gtk-update-icon-cache -f -q "$ICON_SCARLET_TARGET" 2>/dev/null || true
  success "  Tela-circle-hotred installed"
else
  info "  Tela-circle-hotred already installed"
fi

# --- Vivid-Glassy-Dark-Icons (from Another-World repo) ---
ICON_VIVID_TARGET="${ICON_DIR}/Vivid-Glassy-Dark-Icons"
if [[ ! -d "$ICON_VIVID_TARGET" ]]; then
  log "  Downloading Vivid-Glassy-Dark-Icons..."
  if [[ ! -f "$TMP_DIR/another-world.tar.gz" ]]; then
    curl -fsSL "https://github.com/cyb3rgh0u1/Another-World/archive/refs/heads/main.tar.gz" \
      -o "$TMP_DIR/another-world.tar.gz"
    AW_SRC="${TMP_DIR}/another"
    mkdir -p "$AW_SRC"
    tar -xzf "$TMP_DIR/another-world.tar.gz" -C "$AW_SRC" --strip-components=1
  fi
  tar -xzf "$AW_SRC/Source/arcs/Icon_Vivid-Glassy-Dark.tar.gz" -C "$ICON_DIR"
  ln -sfn "$ICON_VIVID_TARGET" "${HOME}/.icons/Vivid-Glassy-Dark-Icons"
  gtk-update-icon-cache -f -q "$ICON_VIVID_TARGET" 2>/dev/null || true
  success "  Vivid-Glassy-Dark-Icons installed"
else
  info "  Vivid-Glassy-Dark-Icons already installed"
fi

# --- MacOS (from hyde-gallery Mac-Os branch) ---
ICON_MACOS_TARGET="${ICON_DIR}/MacOS"
if [[ ! -d "$ICON_MACOS_TARGET" ]]; then
  log "  Downloading MacOS icons..."
  if [[ ! -f "$TMP_DIR/mac-os-theme.tar.gz" ]]; then
    curl -fsSL "https://github.com/HyDE-Project/hyde-gallery/archive/refs/heads/Mac-Os.tar.gz" \
      -o "$TMP_DIR/mac-os-theme.tar.gz"
    MACOS_SRC="${TMP_DIR}/macos"
    mkdir -p "$MACOS_SRC"
    tar -xzf "$TMP_DIR/mac-os-theme.tar.gz" -C "$MACOS_SRC" --strip-components=1
  fi
  tar -xJf "$MACOS_SRC/Source/arcs/Icon_Mac OS.tar.xz" -C "$ICON_DIR"
  ln -sfn "$ICON_MACOS_TARGET" "${HOME}/.icons/MacOS"
  gtk-update-icon-cache -f -q "$ICON_MACOS_TARGET" 2>/dev/null || true
  success "  MacOS icons installed"
else
  info "  MacOS icons already installed"
fi

# --- Windows-11 icons (from hyde-gallery Windows-11 branch) ---
ICON_WIN_TARGET="${ICON_DIR}/Windows-11"
if [[ ! -d "$ICON_WIN_TARGET" ]]; then
  log "  Downloading Windows-11 icons..."
  if [[ ! -f "$TMP_DIR/windows-11-theme.tar.gz" ]]; then
    curl -fsSL "https://github.com/HyDE-Project/hyde-gallery/archive/refs/heads/Windows-11.tar.gz" \
      -o "$TMP_DIR/windows-11-theme.tar.gz"
    WIN_SRC="${TMP_DIR}/win11"
    mkdir -p "$WIN_SRC"
    tar -xzf "$TMP_DIR/windows-11-theme.tar.gz" -C "$WIN_SRC" --strip-components=1
  fi
  tar -xzf "$WIN_SRC/Source/arcs/Icon_Windows 11.tar.gz" -C "$ICON_DIR"
  ln -sfn "$ICON_WIN_TARGET" "${HOME}/.icons/Windows-11"
  gtk-update-icon-cache -f -q "$ICON_WIN_TARGET" 2>/dev/null || true
  success "  Windows-11 icons installed"
else
  info "  Windows-11 icons already installed"
fi

# --- Tela-circle-solarized (from Solarized-Dark repo) ---
ICON_TELA_SOLARIZED_TARGET="${ICON_DIR}/Tela-circle-solarized"
if [[ ! -d "$ICON_TELA_SOLARIZED_TARGET" ]]; then
  log "  Downloading Tela-circle-solarized..."
  if [[ ! -f "$TMP_DIR/solarized-dark.tar.gz" ]]; then
    curl -fsSL "https://github.com/rishav12s/Solarized-Dark/archive/refs/heads/Solarized-Dark.tar.gz" \
      -o "$TMP_DIR/solarized-dark.tar.gz"
    SD_SRC="${TMP_DIR}/solarized"
    mkdir -p "$SD_SRC"
    tar -xzf "$TMP_DIR/solarized-dark.tar.gz" -C "$SD_SRC" --strip-components=1
  fi
  tar -xzf "$SD_SRC/Source/arcs/Icon_Tela-circle-solarized.tar.gz" -C "$ICON_DIR"
  ln -sfn "$ICON_TELA_SOLARIZED_TARGET" "${HOME}/.icons/Tela-circle-solarized"
  gtk-update-icon-cache -f -q "$ICON_TELA_SOLARIZED_TARGET" 2>/dev/null || true
  success "  Tela-circle-solarized installed"
else
  info "  Tela-circle-solarized already installed"
fi

# --- AUR icon packages ---
install_aur_pkg "tela-circle-icon-theme-all"
install_aur_pkg "nordzy-icon-theme"
install_aur_pkg "gruvbox-plus-icon-theme"

success "All icon themes installed"
