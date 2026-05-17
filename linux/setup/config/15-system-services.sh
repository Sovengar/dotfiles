#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Configuring system services..."

if ! command -v systemctl &>/dev/null; then
  log "systemctl not found, skipping service configuration"
  return
fi

enable_service_if_present() {
  local service="$1"
  if systemctl list-unit-files "$service" &>/dev/null; then
    _ensure_sudo
    sudo systemctl enable --now "$service"
    success "$service enabled"
  else
    log "$service not found, skipping"
  fi
}

enable_service_if_present NetworkManager.service
enable_service_if_present bluetooth.service

success "System services configured"
