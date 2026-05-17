#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing Podman Desktop..."
if _cmd_present podman-desktop; then success "podman-desktop already installed"; else pkg_install podman-desktop; success "podman-desktop installed"; fi
