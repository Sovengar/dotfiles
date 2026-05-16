#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing Engram..."

if ! _cmd_present git; then
  err "git is required to install Engram"
  exit 1
fi

if ! _cmd_present go; then
  err "go is required to install Engram"
  exit 1
fi

src_dir="$HOME/src/engram"
mkdir -p "$(dirname "$src_dir")"

if [[ -d "$src_dir/.git" ]]; then
  log "Updating Engram source..."
  git -C "$src_dir" pull --ff-only
else
  git clone https://github.com/Gentleman-Programming/engram.git "$src_dir"
fi

(
  cd "$src_dir"
  go install ./cmd/engram
)

if _cmd_present engram; then
  success "Engram installed"
else
  go_bin="$(go env GOPATH)/bin"
  warn "Engram installed to $go_bin, but it is not available in PATH"
fi
