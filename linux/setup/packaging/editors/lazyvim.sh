#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing LazyVim dependencies..."
if tree-sitter --version &>/dev/null; then
  success "tree-sitter-cli already installed"
else
  log "Installing npm global: tree-sitter-cli"
  if command -v mise &>/dev/null; then
    mise exec node -- npm install -g tree-sitter-cli
  else
    npm install -g tree-sitter-cli
  fi
  success "tree-sitter-cli installed"
fi
