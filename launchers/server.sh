#!/usr/bin/env bash
#
# Public launcher for linux-server (Ubuntu Server headless).
# This script lives in the PUBLIC repo (Sovengar/dotfiles).
# It installs git + gh, logs into GitHub, clones the PRIVATE repo,
# and delegates to its full installer.
#
# Usage:
#   curl -fsL https://raw.githubusercontent.com/Sovengar/dotfiles/master/launchers/server.sh | bash
#
set -eEuo pipefail

REPO_URL="https://github.com/Sovengar/dotfiles-linux-server.git"
REPO_DIR="${DOTFILES_DIR:-$HOME/.local/share/chezmoi}"

# ── Install git ─────────────────────────────────────────────────

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
    echo "No supported package manager found to install git" >&2
    exit 1
  fi
}

# ── Install GitHub CLI ──────────────────────────────────────────

install_gh() {
  if command -v gh &>/dev/null; then
    return 0
  fi

  if command -v apt &>/dev/null; then
    (sudo apt update && sudo apt install -y gh) || {
      # Older Ubuntu: use official install script
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
      sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
      sudo apt update
      sudo apt install -y gh
    }
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm --needed github-cli
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

# ── Auth to GitHub ──────────────────────────────────────────────

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
  echo "To clone private dotfiles, you need to authenticate with GitHub."
  echo ""
  echo "This server may not have a browser. gh will show a device code."
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

# ── Clone and delegate ──────────────────────────────────────────

install_git
install_gh
auth_github

if [[ -d "$REPO_DIR/.git" ]]; then
  echo "Repo exists. Pulling latest..."
  git -C "$REPO_DIR" pull --ff-only
else
  echo "Cloning $REPO_URL ..."
  mkdir -p "$(dirname "$REPO_DIR")"
  git clone "$REPO_URL" "$REPO_DIR"
fi

echo ""
echo "Launcher done. Running private installer..."
echo ""
exec "$REPO_DIR/setup/install.sh"
