#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing Engram..."

repo="https://github.com/Gentleman-Programming/engram.git"
module="github.com/Gentleman-Programming/engram/cmd/engram"

if ! _cmd_present git; then
  err "git is required to install Engram"
  exit 1
fi

if ! _cmd_present go; then
  err "go is required to install Engram"
  exit 1
fi

latest_version() {
  git ls-remote --tags --refs "$repo" 'refs/tags/v*' \
    | sed -n 's#.*refs/tags/v\([0-9][0-9.]*\)$#\1#p' \
    | sort -V \
    | tail -n 1
}

installed_version() {
  engram --version 2>/dev/null \
    | sed -n 's/^engram //p' \
    | head -n 1
}

version_gt() {
  [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -n 1)" == "$1" && "$1" != "$2" ]]
}

remote_version="$(latest_version)"

if [[ -z "$remote_version" ]]; then
  err "Could not determine latest Engram version"
  exit 1
fi

if _cmd_present engram; then
  current_version="$(installed_version)"
  if [[ -z "$current_version" ]]; then
    warn "Engram is installed but its version could not be determined; installing v$remote_version"
  elif version_gt "$remote_version" "$current_version"; then
    log "Engram update available: $current_version -> $remote_version"
  else
    success "Engram already up to date ($current_version)"
    return 0 2>/dev/null || exit 0
  fi
else
  log "Engram not installed; installing v$remote_version"
fi

go install "$module@v$remote_version"

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
