#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing lazygit..."

if _cmd_present lazygit; then
  success "lazygit already installed"
elif pkg_install lazygit 2>/dev/null; then
  success "lazygit installed"
else
  warn "not in official repos, falling back to GitHub releases..."
  version="$(curl -fsL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name"' | cut -d'"' -f4)"
  curl -fsL "https://github.com/jesseduffield/lazygit/releases/download/$version/lazygit_${version#v}_Linux_x86_64.tar.gz" \
    | tar xz -C /tmp
  _ensure_sudo
  sudo install /tmp/lazygit /usr/local/bin/
  success "lazygit $version installed"
fi
