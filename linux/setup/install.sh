#!/usr/bin/env bash
#
# omarchy:summary=Bootstrap a Linux machine: git + chezmoi + dotfiles + packages
#
# Usage:
#   curl -fsL https://raw.githubusercontent.com/Sovengar/dotfiles/master/linux/setup/install.sh | bash
#
# This is the single entry point. It orchestrates all phases:
#   preflight → packaging → config → post-install
#
set -eEuo pipefail

export DEBIAN_FRONTEND=noninteractive

REPO_URL="https://github.com/Sovengar/dotfiles"
REPO_DIR="${DOTFILES_DIR:-$HOME/.local/share/chezmoi}"

install_git() {
  if command -v git &>/dev/null; then
    return 0
  fi

  if command -v apt &>/dev/null; then
    sudo apt update
    sudo apt install -y git
  elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm --needed git
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y git
  elif command -v brew &>/dev/null; then
    brew install git
  else
    echo "No supported package manager found to install git (apt/pacman/dnf/brew)" >&2
    exit 1
  fi
}

# When executed through `curl | bash`, only this file exists locally. Bootstrap
# the full repo first, then re-run the local installer so helpers and phases are
# available from disk.
if [[ ! -f "${BASH_SOURCE[0]}" ]]; then
  install_git

  if [[ -d "$REPO_DIR/.git" ]]; then
    git -C "$REPO_DIR" pull --ff-only
  else
    mkdir -p "$(dirname "$REPO_DIR")"
    git clone "$REPO_URL" "$REPO_DIR"
  fi

  cd "$REPO_DIR"
  exec "$REPO_DIR/linux/setup/install.sh"
fi

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SETUP_DIR

# ── Helpers ────────────────────────────────────────────────────
source "$SETUP_DIR/helpers/all.sh"

# ── Banner ─────────────────────────────────────────────────────
display_banner

# ── Phases ─────────────────────────────────────────────────────
run_phase "$SETUP_DIR/preflight"
run_phase "$SETUP_DIR/packaging"
run_phase "$SETUP_DIR/config"
run_phase "$SETUP_DIR/setup"
run_phase "$SETUP_DIR/post-install"
