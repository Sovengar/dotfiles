#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing ClockTemp..."

if _cmd_present clocktemp; then
  success "ClockTemp already installed"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  pkg_install python-requests

  TMPDIR=$(mktemp -d)
  git clone --depth=1 https://github.com/arthur-dnts/ClockTemp.git "$TMPDIR/ClockTemp"
  pushd "$TMPDIR/ClockTemp/script" >/dev/null
  sudo ./install.sh
  popd >/dev/null
  rm -rf "$TMPDIR"
  success "ClockTemp installed"
fi
