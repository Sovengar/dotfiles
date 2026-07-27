#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing JMeter..."
if _cmd_present jmeter; then success "JMeter already installed"; else detect_pkg_manager >/dev/null; case "$_pkg_manager" in pacman) aur_install jmeter ;; *) _ensure_sudo; pkg_install jmeter ;; esac; success "JMeter installed"; fi
