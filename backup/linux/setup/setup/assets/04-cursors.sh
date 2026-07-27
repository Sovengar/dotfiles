#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing cursor themes..."

ICON_DIR="${HOME}/.local/share/icons"

TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

mkdir -p "$ICON_DIR" "${HOME}/.icons"

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

# --- Sweet-cursors (from Paranoid-Sweet repo) ---
CURSOR_SWEET_TARGET="${ICON_DIR}/Sweet-cursors"
if [[ ! -d "$CURSOR_SWEET_TARGET" ]]; then
  log "  Downloading Sweet-cursors..."
  curl -fsSL "https://github.com/rishav12s/Paranoid-Sweet/archive/303ec22d4d1276a636466f61eb71be28a1ef2a85.tar.gz" \
    -o "$TMP_DIR/paranoid-sweet.tar.gz"
  PARANOID_SRC="${TMP_DIR}/paranoid"
  mkdir -p "$PARANOID_SRC"
  tar -xzf "$TMP_DIR/paranoid-sweet.tar.gz" -C "$PARANOID_SRC" --strip-components=1
  tar -xzf "$PARANOID_SRC/Source/arcs/Cursor_Sweet.tar.gz" -C "$ICON_DIR"
  success "  Sweet-cursors installed"
else
  info "  Sweet-cursors already installed"
fi

# --- Capitaine-Cursors (from Oxo-Carbon repo) ---
CURSOR_CAPITAINE_TARGET="${ICON_DIR}/Capitaine-Cursors"
if [[ ! -d "$CURSOR_CAPITAINE_TARGET" ]]; then
  log "  Downloading Capitaine-Cursors..."
  curl -fsSL "https://github.com/rishav12s/Oxo-Carbon/archive/refs/heads/Oxo-Carbon.tar.gz" \
    -o "$TMP_DIR/oxo-carbon.tar.gz"
  OXO_SRC="${TMP_DIR}/oxo"
  mkdir -p "$OXO_SRC"
  tar -xzf "$TMP_DIR/oxo-carbon.tar.gz" -C "$OXO_SRC" --strip-components=1
  tar -xf "$OXO_SRC/Source/arcs/Cursor_Capitaine-Cursors.tar.xz" -C "$ICON_DIR"
  ln -sfn "$CURSOR_CAPITAINE_TARGET" "${HOME}/.icons/Capitaine-Cursors"
  success "  Capitaine-Cursors installed"
else
  info "  Capitaine-Cursors already installed"
fi

# --- pixel-dream-cursor ---
CURSOR_PIXEL_TARGET="${HOME}/.icons/pixel-dream-cursor"
if [[ ! -d "$CURSOR_PIXEL_TARGET" ]]; then
  log "  Downloading pixel-dream-cursor..."
  curl -fsSL "https://github.com/rishav12s/Pixel-Dream/archive/79607bbf37c356acb80992c8302ada3336f9d8fa.tar.gz" \
    -o "$TMP_DIR/pixel-dream.tar.gz"
  PD_SRC="${TMP_DIR}/pixel-dream"
  mkdir -p "$PD_SRC"
  tar -xzf "$TMP_DIR/pixel-dream.tar.gz" -C "$PD_SRC" --strip-components=1
  tar -xzf "$PD_SRC/Source/arcs/Cursor_pixel-dream-cursor.tar.gz" -C "${HOME}/.icons"
  success "  pixel-dream-cursor installed"
else
  info "  pixel-dream-cursor already installed"
fi

# --- Bibata-Modern-Classic ---
CURSOR_BIBATA_TARGET="${ICON_DIR}/Bibata-Modern-Classic"
if [[ -d "$CURSOR_BIBATA_TARGET" ]]; then
  info "  Bibata-Modern-Classic already installed"
else
  log "  Installing Bibata-Modern-Classic..."
  if command -v paru &>/dev/null; then
    if paru -S --noconfirm bibata-cursor-theme 2>&1; then
      success "  Bibata-Modern-Classic installed via paru"
    else
      warn "  paru failed, falling back to direct download..."
    fi
  fi
  if [[ ! -d "$CURSOR_BIBATA_TARGET" ]]; then
    curl -fsSL "https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Classic.tar.xz" \
      -o "$TMP_DIR/bibata.tar.xz"
    tar -xf "$TMP_DIR/bibata.tar.xz" -C "$ICON_DIR"
    success "  Bibata-Modern-Classic installed"
  fi
fi

# --- Bibata-Modern-Ice (from Vanta-Black repo) ---
CURSOR_BIBATA_ICE_TARGET="${ICON_DIR}/Bibata-Modern-Ice"
if [[ ! -d "$CURSOR_BIBATA_ICE_TARGET" ]]; then
  log "  Downloading Bibata-Modern-Ice (Vanta-Black)..."
  if [[ ! -f "$TMP_DIR/vanta-black.tar.gz" ]]; then
    curl -fsSL "https://github.com/rishav12s/Vanta-Black/archive/refs/heads/Vanta-Black.tar.gz" \
      -o "$TMP_DIR/vanta-black.tar.gz"
    VB_SRC="${TMP_DIR}/vanta"
    mkdir -p "$VB_SRC"
    tar -xzf "$TMP_DIR/vanta-black.tar.gz" -C "$VB_SRC" --strip-components=1
  fi
  tar -xf "$VB_SRC/Source/arcs/Cursor_Bibata-Modern-Ice.tar.gz" -C "$ICON_DIR"
  ln -sfn "$CURSOR_BIBATA_ICE_TARGET" "${HOME}/.icons/Bibata-Modern-Ice"
  ln -sfn "$CURSOR_BIBATA_ICE_TARGET" "${HOME}/.cursors/Bibata-Modern-Ice"
  success "  Bibata-Modern-Ice installed"
else
  info "  Bibata-Modern-Ice already installed"
fi

# --- Capitaine-Cursors-Tokyonight (from Rain-Dark repo) ---
CURSOR_CAPITAINE_TN_TARGET="${ICON_DIR}/Capitaine-Cursors-Tokyonight"
if [[ ! -d "$CURSOR_CAPITAINE_TN_TARGET" ]]; then
  log "  Downloading Capitaine-Cursors-Tokyonight..."
  if [[ ! -f "$TMP_DIR/rain-dark.tar.gz" ]]; then
    curl -fsSL "https://github.com/rishav12s/Rain-Dark/archive/refs/heads/Rain-Dark.tar.gz" \
      -o "$TMP_DIR/rain-dark.tar.gz"
    RD_SRC="${TMP_DIR}/rain"
    mkdir -p "$RD_SRC"
    tar -xzf "$TMP_DIR/rain-dark.tar.gz" -C "$RD_SRC" --strip-components=1
  fi
  tar -xf "$RD_SRC/Source/arcs/Cursor_Capitaine-Cursors-Tokyonight.tar.xz" -C "$ICON_DIR"
  ln -sfn "$CURSOR_CAPITAINE_TN_TARGET" "${HOME}/.icons/Capitaine-Cursors-Tokyonight"
  ln -sfn "$CURSOR_CAPITAINE_TN_TARGET" "${HOME}/.cursors/Capitaine-Cursors-Tokyonight"
  success "  Capitaine-Cursors-Tokyonight installed"
else
  info "  Capitaine-Cursors-Tokyonight already installed"
fi

# --- Future-cyan-cursors (from Crimson-Blade repo) ---
CURSOR_CRIMSON_TARGET="${ICON_DIR}/Future-cyan-cursors"
if [[ ! -d "$CURSOR_CRIMSON_TARGET" ]]; then
  log "  Downloading Future-cyan-cursors..."
  if [[ ! -f "$TMP_DIR/crimson-blade.tar.gz" ]]; then
    curl -fsSL "https://github.com/cyb3rgh0u1/Crimson-Blade/archive/refs/heads/main.tar.gz" \
      -o "$TMP_DIR/crimson-blade.tar.gz"
    CB_SRC="${TMP_DIR}/crimson"
    mkdir -p "$CB_SRC"
    tar -xzf "$TMP_DIR/crimson-blade.tar.gz" -C "$CB_SRC" --strip-components=1
  fi
  tar -xzf "$CB_SRC/Source/arcs/Cursor_future-cyan.tar.gz" -C "$ICON_DIR"
  ln -sfn "$CURSOR_CRIMSON_TARGET" "${HOME}/.icons/Future-cyan-cursors"
  ln -sfn "$CURSOR_CRIMSON_TARGET" "${HOME}/.cursors/Future-cyan-cursors"
  success "  Future-cyan-cursors installed"
else
  info "  Future-cyan-cursors already installed"
fi

# --- MacOS-Cursor (from hyde-gallery Mac-Os branch) ---
CURSOR_MACOS_TARGET="${ICON_DIR}/MacOS-Cursor"
if [[ ! -d "$CURSOR_MACOS_TARGET" ]]; then
  log "  Downloading MacOS-Cursor..."
  if [[ ! -f "$TMP_DIR/mac-os-theme.tar.gz" ]]; then
    curl -fsSL "https://github.com/HyDE-Project/hyde-gallery/archive/refs/heads/Mac-Os.tar.gz" \
      -o "$TMP_DIR/mac-os-theme.tar.gz"
    MACOS_SRC="${TMP_DIR}/macos"
    mkdir -p "$MACOS_SRC"
    tar -xzf "$TMP_DIR/mac-os-theme.tar.gz" -C "$MACOS_SRC" --strip-components=1
  fi
  tar -xzf "$MACOS_SRC/Source/arcs/Cursor_Mac OS.tar.gz" -C "$ICON_DIR"
  ln -sfn "$CURSOR_MACOS_TARGET" "${HOME}/.icons/MacOS-Cursor"
  ln -sfn "$CURSOR_MACOS_TARGET" "${HOME}/.cursors/MacOS-Cursor"
  success "  MacOS-Cursor installed"
else
  info "  MacOS-Cursor already installed"
fi

# --- Cursor-Windows (from hyde-gallery Windows-11 branch) ---
CURSOR_WIN_TARGET="${ICON_DIR}/Cursor-Windows"
if [[ ! -d "$CURSOR_WIN_TARGET" ]]; then
  log "  Downloading Cursor-Windows..."
  if [[ ! -f "$TMP_DIR/windows-11-theme.tar.gz" ]]; then
    curl -fsSL "https://github.com/HyDE-Project/hyde-gallery/archive/refs/heads/Windows-11.tar.gz" \
      -o "$TMP_DIR/windows-11-theme.tar.gz"
    WIN_SRC="${TMP_DIR}/win11"
    mkdir -p "$WIN_SRC"
    tar -xzf "$TMP_DIR/windows-11-theme.tar.gz" -C "$WIN_SRC" --strip-components=1
  fi
  tar -xzf "$WIN_SRC/Source/arcs/Cursor_Windows 11.tar.gz" -C "$ICON_DIR"
  ln -sfn "$CURSOR_WIN_TARGET" "${HOME}/.icons/Cursor-Windows"
  ln -sfn "$CURSOR_WIN_TARGET" "${HOME}/.cursors/Cursor-Windows"
  success "  Cursor-Windows installed"
else
  info "  Cursor-Windows already installed"
fi

# --- Capitaine-Cursors-White (from Solarized-Dark repo) ---
CURSOR_CAPITAINE_WHITE_TARGET="${ICON_DIR}/Capitaine-Cursors-White"
if [[ ! -d "$CURSOR_CAPITAINE_WHITE_TARGET" ]]; then
  log "  Downloading Capitaine-Cursors-White..."
  if [[ ! -f "$TMP_DIR/solarized-dark.tar.gz" ]]; then
    curl -fsSL "https://github.com/rishav12s/Solarized-Dark/archive/refs/heads/Solarized-Dark.tar.gz" \
      -o "$TMP_DIR/solarized-dark.tar.gz"
    SD_SRC="${TMP_DIR}/solarized"
    mkdir -p "$SD_SRC"
    tar -xzf "$TMP_DIR/solarized-dark.tar.gz" -C "$SD_SRC" --strip-components=1
  fi
  tar -xf "$SD_SRC/Source/arcs/Cursor_Capitaine-Cursors-White.tar.xz" -C "$ICON_DIR"
  ln -sfn "$CURSOR_CAPITAINE_WHITE_TARGET" "${HOME}/.icons/Capitaine-Cursors-White"
  ln -sfn "$CURSOR_CAPITAINE_WHITE_TARGET" "${HOME}/.cursors/Capitaine-Cursors-White"
  success "  Capitaine-Cursors-White installed"
else
  info "  Capitaine-Cursors-White already installed"
fi

# --- AUR cursor packages ---
install_aur_pkg "bibata-cursor-translucent"
install_aur_pkg "beautyline"

success "All cursor themes installed"
