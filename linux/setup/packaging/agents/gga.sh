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

src_dir="$HOME/src/gentleman-guardian-angel"
mkdir -p "$(dirname "$src_dir")"

if [[ -d "$src_dir/.git" ]]; then
  log "Updating Gentleman Guardian Angel source..."
  git -C "$src_dir" pull --ff-only
else
  git clone https://github.com/Gentleman-Programming/gentleman-guardian-angel.git "$src_dir"
fi

bash "$src_dir/install.sh"

if _cmd_present gga; then
  success "Gentleman Guardian Angel installed"
else
  warn "Gentleman Guardian Angel installed, but gga is not available in PATH"
fi
