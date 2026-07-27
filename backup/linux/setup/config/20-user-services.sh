#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Configuring user services..."

if ! command -v systemctl &>/dev/null; then
  log "systemctl not found, skipping user service configuration"
  return
fi

enable_user_service_if_present() {
  local service="$1"
  if ! systemctl --user list-unit-files "$service" &>/dev/null; then
    log "$service user service not found, skipping"
    return
  fi

  if systemctl --user is-enabled --quiet "$service" 2>/dev/null; then
    log "$service already enabled"
    systemctl --user start "$service" 2>/dev/null || warn "Could not start $service"
    return
  fi

  if systemctl --user enable --now "$service" 2>/dev/null; then
    success "$service enabled"
  else
    warn "Could not enable $service"
  fi
}

enable_user_service_if_present hyprpolkitagent.service

success "User services configured"
