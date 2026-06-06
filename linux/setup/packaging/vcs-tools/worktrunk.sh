#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing worktrunk..."
if _cmd_present wt; then success "worktrunk already installed"; else detect_pkg_manager >/dev/null; _ensure_sudo; case "$_pkg_manager" in pacman) pkg_install worktrunk ;; *) pkg_install worktrunk ;; esac; success "worktrunk installed"; fi
