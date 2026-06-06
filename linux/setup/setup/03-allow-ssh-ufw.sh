#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Allowing SSH through UFW..."

if ! _cmd_present ufw; then
  log "ufw not found, skipping SSH firewall rule"
  return 0 2>/dev/null || exit 0
fi

_ensure_sudo
sudo ufw allow 22/tcp
success "SSH allowed through UFW"
