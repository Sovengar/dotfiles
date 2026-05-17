#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing GitHub CLI..."
if _cmd_present gh; then success "gh already installed"; else detect_pkg_manager >/dev/null; _ensure_sudo; case "$_pkg_manager" in pacman) pkg_install github-cli ;; *) pkg_install gh ;; esac; success "gh installed"; fi
