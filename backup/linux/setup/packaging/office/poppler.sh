#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing poppler..."
if _cmd_present pdftotext; then
  success "poppler already installed"
  return 0 2>/dev/null || exit 0
fi
detect_pkg_manager >/dev/null
_ensure_sudo
case "$_pkg_manager" in
  apt|dnf) pkg_install poppler-utils ;;
  pacman) pkg_install poppler ;;
  brew) pkg_install poppler ;;
esac
success "poppler installed"
