#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing pastel..."
if _cmd_present pastel; then success "pastel already installed"; else detect_pkg_manager >/dev/null; _ensure_sudo; pkg_install pastel; success "pastel installed"; fi
