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

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

git clone --depth 1 https://github.com/Gentleman-Programming/engram.git "$tmp_dir"

(
  cd "$tmp_dir"
  go install ./cmd/engram
)

go_bin="$(go env GOPATH)/bin"
engram_bin="$go_bin/engram"
local_bin="$HOME/.local/bin"
target_bin="$local_bin/engram"

if [[ ! -x "$engram_bin" ]]; then
  err "Engram binary was not created at $engram_bin"
  exit 1
fi

mkdir -p "$local_bin"
mv -f "$engram_bin" "$target_bin"
chmod +x "$target_bin"

if _cmd_present engram; then
  success "Engram installed to $target_bin"
else
  warn "Engram installed to $target_bin, but ~/.local/bin is not available in PATH"
fi
