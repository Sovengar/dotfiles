#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing mise..."
if _cmd_present mise; then
  success "mise already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  pkg_install mise
  success "mise installed"
fi

log "Installing mise tools (python, node, go, etc.)..."
mise install 2>/dev/null || true
success "mise tools installed"

log "Installing Python utility packages (required by AUR builds)..."
_python="$(mise which python 2>/dev/null || true)"
if [[ -n "$_python" && -x "$_python" ]]; then
  "$_python" -m pip install --quiet setuptools build 2>/dev/null || true
  success "python-build + setuptools installed"
else
  warn "mise python not found, skipping python-build"
fi
