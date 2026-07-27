#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Setting default shell to fish..."

FISH_PATH="$(command -v fish 2>/dev/null || echo "/usr/bin/fish")"

if [[ "$SHELL" == "$FISH_PATH" ]] || [[ "$(getent passwd "$USER" | cut -d: -f7)" == "$FISH_PATH" ]]; then
  success "fish is already the default shell"
  log "Log out and back in (or reboot) for the new shell to take effect in all sessions"
  return
fi

if ! _cmd_present fish; then
  warn "fish is not installed — skipping default shell change"
  return
fi

sudo chsh -s "$FISH_PATH" "$USER"
success "Default shell changed to fish. Changes take effect on next login."
