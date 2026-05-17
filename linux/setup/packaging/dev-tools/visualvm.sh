#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing VisualVM..."
if _cmd_present visualvm; then success "VisualVM already installed"; else detect_pkg_manager >/dev/null; case "$_pkg_manager" in pacman) aur_install visualvm ;; *) _ensure_sudo; pkg_install visualvm ;; esac; success "VisualVM installed"; fi
