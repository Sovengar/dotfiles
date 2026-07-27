#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing LazyVim dependencies..."
if _cmd_present tree-sitter; then
  success "tree-sitter-cli already installed"
elif pkg_install tree-sitter-cli 2>/dev/null; then
  success "tree-sitter-cli installed"
else
  warn "not in official repos, falling back to npm..."
  if command -v mise &>/dev/null; then
    mise exec node -- npm install -g tree-sitter-cli
  else
    npm install -g tree-sitter-cli
  fi
  success "tree-sitter-cli installed"
fi
