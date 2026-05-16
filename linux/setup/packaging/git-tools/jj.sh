#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing jj..."
if _cmd_present jj; then success "jj already installed"; else detect_pkg_manager >/dev/null; _ensure_sudo; case "$_pkg_manager" in pacman) pkg_install jujutsu ;; *) pkg_install jj ;; esac; success "jj installed"; fi
