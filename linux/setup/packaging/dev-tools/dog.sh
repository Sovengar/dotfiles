#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi
log "Installing dog (dog-dns)..."
if _cmd_present dog; then
  success "dog already installed"
elif pkg_install dog 2>/dev/null; then
  success "dog installed"
else
  warn "not in official repos, falling back to manual download..."
  _dog_url="https://github.com/ogham/dog/releases/download/v0.1.0/dog-v0.1.0-x86_64-unknown-linux-gnu.zip"
  _dog_tmp="$(mktemp -d)"
  curl -fsSL "$_dog_url" -o "$_dog_tmp/dog.zip"
  unzip -o "$_dog_tmp/dog.zip" -d "$_dog_tmp" bin/dog
  chmod +x "$_dog_tmp/bin/dog"
  mkdir -p "$HOME/.local/bin"
  mv -f "$_dog_tmp/bin/dog" "$HOME/.local/bin/dog"
  rm -rf "$_dog_tmp"
  success "dog installed to ~/.local/bin/dog"
fi
