#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing zoxide..."

if _cmd_present zoxide; then
  log "zoxide already installed"
else
  curl -fsS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
  success "zoxide installed"
fi
