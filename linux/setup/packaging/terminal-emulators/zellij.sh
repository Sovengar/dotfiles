#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing zellij..."

if _cmd_present zellij; then
  success "zellij already installed"
elif [[ -x "$HOME/.cargo/bin/zellij" ]]; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$HOME/.cargo/bin/zellij" "$HOME/.local/bin/zellij"
  success "zellij linked to ~/.local/bin/zellij"
elif _cmd_present cargo; then
  cargo install --locked zellij
  if [[ -x "$HOME/.cargo/bin/zellij" ]]; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.cargo/bin/zellij" "$HOME/.local/bin/zellij"
  fi
  success "zellij installed with cargo"
else
  detect_pkg_manager >/dev/null
  _ensure_sudo
  pkg_install zellij
  success "zellij installed"
fi
