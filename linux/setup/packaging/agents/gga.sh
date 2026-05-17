#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing Gentleman Guardian Angel..."

if ! _cmd_present git; then
  err "git is required to install Gentleman Guardian Angel"
  exit 1
fi

if _cmd_present gga; then
  success "Gentleman Guardian Angel already installed; skipping reinstall"
  exit 0
fi

if [[ -w "/usr/local/bin" ]]; then
  install_dir="/usr/local/bin"
else
  install_dir="$HOME/.local/bin"
fi

if [[ -f "$install_dir/gga" ]]; then
  success "Gentleman Guardian Angel already installed at $install_dir/gga; skipping reinstall"
  exit 0
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

git clone --depth 1 https://github.com/Gentleman-Programming/gentleman-guardian-angel.git "$tmp_dir"

bash "$tmp_dir/install.sh"

if _cmd_present gga; then
  success "Gentleman Guardian Angel installed"
else
  warn "Gentleman Guardian Angel installed, but gga is not available in PATH"
fi
