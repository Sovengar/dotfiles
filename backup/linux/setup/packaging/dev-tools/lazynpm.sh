#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing lazynpm..."

if _cmd_present lazynpm; then
  success "lazynpm already installed"
elif command -v brew &>/dev/null; then
  brew install jesseduffield/lazynpm/lazynpm
  success "lazynpm installed"
else
  warn "brew not available, skipping lazynpm (tap: jesseduffield/lazynpm)"
fi
