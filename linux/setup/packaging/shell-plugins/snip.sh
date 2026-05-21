#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing snip..."
go_install_latest "github.com/edouard-claude/snip/cmd/snip@latest" snip

if ! command -v snip &>/dev/null && [[ -f "$(go env GOBIN)/snip" ]]; then
  mkdir -p "$HOME/.local/bin"
  mv -f "$(go env GOBIN)/snip" "$HOME/.local/bin/snip"
  success "snip moved to ~/.local/bin"
fi
