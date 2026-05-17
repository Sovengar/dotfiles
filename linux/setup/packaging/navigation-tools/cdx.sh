#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing cdx..."

BIN_DIR="$HOME/.local/bin"
BIN_PATH="$BIN_DIR/cdx-rs"
REPO_URL="https://github.com/Sovengar/cdx.git"

if [[ -x "$BIN_PATH" ]]; then
  success "cdx already installed"
  return 0 2>/dev/null || exit 0
fi

if ! _cmd_present git; then
  err "git is required to install cdx"
  exit 1
fi

if ! _cmd_present cargo; then
  err "cargo is required to install cdx"
  exit 1
fi

BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

git clone --depth 1 "$REPO_URL" "$BUILD_DIR/cdx"
cargo build --release --manifest-path "$BUILD_DIR/cdx/Cargo.toml"

mkdir -p "$BIN_DIR"
install -m 755 "$BUILD_DIR/cdx/target/release/cdx" "$BIN_PATH"

success "cdx installed to $BIN_PATH"
