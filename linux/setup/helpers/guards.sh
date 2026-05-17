# Guards — system checks, package manager detection, helper commands

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
_GUARDS_LOADED=1

# ── System guards ──────────────────────────────────────────────

guard_root() {
  if [[ $EUID -eq 0 ]]; then
    err "Do not run as root. Run as your normal user (sudo will be used when needed)."
    exit 1
  fi
}

guard_internet() {
  if ! ping -c1 -W2 1.1.1.1 &>/dev/null; then
    err "No internet connection detected"
    exit 1
  fi
}

guard_arch() {
  if [[ ! -f /etc/arch-release ]] && ! command -v pacman &>/dev/null; then
    warn "This script is designed for Arch Linux / CachyOS"
    warn "Continuing anyway, but some steps may fail..."
  fi
}

# ── Package manager detection ──────────────────────────────────

_pkg_manager=""
_pkg_install_cmd=""
_pkg_update_cmd=""

detect_pkg_manager() {
  if [[ -n "$_pkg_manager" ]]; then
    echo "$_pkg_manager"
    return
  fi
  if command -v apt &>/dev/null; then
    _pkg_manager="apt"
    _pkg_install_cmd="sudo apt install -y"
    _pkg_update_cmd="sudo apt update"
  elif command -v pacman &>/dev/null; then
    _pkg_manager="pacman"
    _pkg_install_cmd="sudo pacman -S --noconfirm --needed"
    _pkg_update_cmd="sudo pacman -Sy"
  elif command -v dnf &>/dev/null; then
    _pkg_manager="dnf"
    _pkg_install_cmd="sudo dnf install -y"
    _pkg_update_cmd="sudo dnf check-update || true"
  elif command -v brew &>/dev/null; then
    _pkg_manager="brew"
    _pkg_install_cmd="brew install"
    _pkg_update_cmd="brew update"
  else
    err "No supported package manager found (apt/pacman/dnf/brew)"
    exit 1
  fi
  echo "$_pkg_manager"
}

pkg_install() {
  local manager
  manager=$(detect_pkg_manager)
  local pkgs=()
  for pkg in "$@"; do
    if ! pkg_is_installed "$pkg"; then
      pkgs+=("$pkg")
    fi
  done
  if [[ ${#pkgs[@]} -eq 0 ]]; then
    return 0
  fi
  log "Installing: ${pkgs[*]}"
  case "$manager" in
    apt) sudo apt install -y "${pkgs[@]}" ;;
    pacman) sudo pacman -S --noconfirm --needed "${pkgs[@]}" ;;
    dnf) sudo dnf install -y "${pkgs[@]}" ;;
    brew) brew install "${pkgs[@]}" ;;
  esac
  success "Installed: ${pkgs[*]}"
}

pkg_is_installed() {
  local manager
  manager=$(detect_pkg_manager)
  case "$manager" in
    apt) dpkg -s "$1" &>/dev/null ;;
    pacman) pacman -Q "$1" &>/dev/null ;;
    dnf) rpm -q "$1" &>/dev/null ;;
    brew) brew list "$1" &>/dev/null ;;
  esac
}

aur_helper() {
  if command -v paru &>/dev/null; then
    echo "paru"
  elif command -v yay &>/dev/null; then
    echo "yay"
  else
    err "No AUR helper found (paru/yay) — install one first"
    exit 1
  fi
}

aur_install() {
  local aur
  aur=$(aur_helper)
  log "Installing from AUR via $aur: $*"
  "$aur" -S --noconfirm --needed "$@"
}

npm_global_install() {
  local package="$1"
  local command_name="${2:-$1}"

  # Ensure mise shims are in PATH so npm is found
  if command -v mise &>/dev/null; then
    local mise_bin_paths
    mise_bin_paths="$(mise bin-paths 2>/dev/null || true)"
    while IFS= read -r bin_path; do
      if [[ -d "$bin_path" ]] && [[ ":$PATH:" != *":$bin_path:"* ]]; then
        export PATH="$bin_path:$PATH"
      fi
    done <<< "$mise_bin_paths"
  fi

  if command -v "$command_name" &>/dev/null; then
    log "$package already installed"
  else
    log "Installing npm global: $package"
    npm install -g "$package"
    success "$package installed"
  fi
}

go_install_latest() {
  local package="$1"
  local command_name="$2"
  if command -v "$command_name" &>/dev/null; then
    log "$command_name already installed"
  else
    log "Installing Go tool: $package"
    go install "$package"
    success "$command_name installed"
  fi
}

# ── Helper commands ────────────────────────────────────────────

_cmd_present() { command -v "$1" &>/dev/null; }
_cmd_missing() { ! command -v "$1" &>/dev/null; }

_ensure_sudo() {
  if [[ $EUID -ne 0 ]]; then
    sudo -v
  fi
}

fi
