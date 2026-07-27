#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi

log "Installing git-machete..."
if _cmd_present git-machete; then
  success "git-machete already installed"
else
  # AUR PKGBUILD fails with non-English locale (tests expect English git output)
  # Install via pip instead of AUR to bypass locale-sensitive tests
  _python="$(mise which python 2>/dev/null || true)"
  if [[ -n "$_python" && -x "$_python" ]]; then
    "$_python" -m pip install --quiet git-machete
    success "git-machete installed via pip"
  else
    err "mise python not found, cannot install git-machete"
    exit 1
  fi
fi