#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing carapace..."
if _cmd_present carapace; then
  success "carapace already installed"
else
  aur_install carapace-bin
  success "carapace installed"
fi
