#!/usr/bin/env bash
#
# Public installer for `sftp-gui-client` (yogapc-only script).
# This file lives in the PUBLIC repo (Sovengar/dotfiles); the real script lives
# in the PRIVATE repo Sovengar/dotfiles-yogapc-linux, which is chezmoi-ready.
#
# What it does: installs git + gh if missing, authenticates with GitHub,
# clones the private repo and copies the script to ~/.local/scripts/.
#
# Usage:
#   curl -fsL https://raw.githubusercontent.com/Sovengar/dotfiles/master/scripts/install.sh | bash
#
# Only this script is installed. The private repo also contains
# `pantalla-portatil`; copy it by hand if you need it:
#   install -m755 "$WORK_DIR/home/dot_local/scripts/executable_pantalla-portatil" ~/.local/scripts/
#
set -eEuo pipefail

REPO="dotfiles-yogapc-linux"
REPO_URL="https://github.com/Sovengar/${REPO}.git"
WORK_DIR="${DOTFILES_YOGAPC_DIR:-$HOME/.local/share/$REPO}"
DEST_DIR="${SFTP_DEST_DIR:-$HOME/.local/scripts}"
BIN_NAME="sftp-gui-client"
SRC_REL="home/dot_local/scripts/executable_${BIN_NAME}"

# ── Install git ─────────────────────────────────────────────────

install_git() {
  if command -v git &>/dev/null; then
    return 0
  fi

  if command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm --needed git
  elif command -v apt &>/dev/null; then
    sudo apt update
    sudo apt install -y git
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y git
  elif command -v brew &>/dev/null; then
    brew install git
  else
    echo "No supported package manager found to install git" >&2
    exit 1
  fi
}

# ── Install GitHub CLI ──────────────────────────────────────────

install_gh() {
  if command -v gh &>/dev/null; then
    return 0
  fi

  if command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm --needed github-cli
  elif command -v apt &>/dev/null; then
    (sudo apt update && sudo apt install -y gh) || {
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
      sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
      sudo apt update
      sudo apt install -y gh
    }
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y 'dnf-command(config-manager)'
    sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo dnf install -y gh
  elif command -v brew &>/dev/null; then
    brew install gh
  else
    curl -fsSL https://github.com/cli/cli/releases/latest/download/gh_Linux_amd64.tar.gz | tar -xz
    sudo mv gh_*/bin/gh /usr/local/bin/gh
  fi
}

# ── Auth to GitHub (the repo is private) ────────────────────────

auth_github() {
  if gh auth status &>/dev/null; then
    echo "GitHub CLI already authenticated."
    return 0
  fi

  echo ""
  echo "==============================================="
  echo "  GITHUB LOGIN REQUIRED"
  echo "==============================================="
  echo ""
  echo "${REPO} is private, so you need to authenticate first."
  echo ""
  echo "If you're on a desktop with a browser, gh will open the login page."
  echo "If you're on a headless box, gh will show a device code:"
  echo "  → Go to https://github.com/login/device on another device"
  echo "  → Enter the code shown below"
  echo ""

  gh auth login --hostname github.com --web --git-protocol https

  if ! gh auth status &>/dev/null; then
    echo "GitHub authentication failed." >&2
    exit 1
  fi

  gh auth setup-git
}

# ── Clone and install ───────────────────────────────────────────

install_git
install_gh
auth_github

if [[ -d "$WORK_DIR/.git" ]]; then
  echo "Repo exists. Pulling latest..."
  git -C "$WORK_DIR" pull --ff-only
else
  echo "Cloning $REPO_URL ..."
  mkdir -p "$(dirname "$WORK_DIR")"
  git clone "$REPO_URL" "$WORK_DIR"
fi

if [[ ! -f "$WORK_DIR/$SRC_REL" ]]; then
  echo "Missing $SRC_REL in $REPO" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
install -m755 "$WORK_DIR/$SRC_REL" "$DEST_DIR/$BIN_NAME"

echo ""
echo "Installed: $DEST_DIR/$BIN_NAME"
echo ""
echo "Try it:"
echo "  $BIN_NAME --help"
echo "  $BIN_NAME --status"
echo ""
echo "Defaults are this machine's LAN (edit via env if needed):"
echo "  SFTP_HOST_ALIAS, SFTP_HOST_IP, SFTP_USER, SFTP_PORT, SFTP_HOME, SFTP_BOOKMARK"
echo ""
echo "Repo with all yogapc-only scripts: $REPO_URL"
