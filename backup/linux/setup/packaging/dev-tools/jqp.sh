#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing jqp..."
go_install_latest "github.com/noahgorstein/jqp@latest" jqp

# go install with mise overrides GOBIN to a dir not in PATH; symlink to ~/.local/bin
if ! command -v jqp &>/dev/null && [[ -f "$(go env GOBIN)/jqp" ]]; then
  mkdir -p "$HOME/.local/bin"
  mv -f "$(go env GOBIN)/jqp" "$HOME/.local/bin/jqp"
  success "jqp moved to ~/.local/bin"
fi
