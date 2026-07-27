#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing GNU sed..."

if _cmd_present sed && sed --version 2>/dev/null | grep -qi gnu; then
  success "GNU sed already installed"
else
  detect_pkg_manager >/dev/null
  case "$_pkg_manager" in
    brew)
      _ensure_sudo
      brew install gnu-sed
      ;;
    *)
      _ensure_sudo
      pkg_install sed
      ;;
  esac
  success "GNU sed installed"
fi
