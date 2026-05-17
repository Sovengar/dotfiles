#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing Doppler CLI..."

if _cmd_present doppler; then
  success "Doppler CLI already installed"
else
  aur_install doppler-cli-bin
  success "Doppler CLI installed"
fi
