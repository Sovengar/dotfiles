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
