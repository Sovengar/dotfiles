#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../../helpers/all.sh"; fi

log "Installing git-wip..."
if _cmd_present git-wip; then
  success "git-wip already installed"
else
  _cmake="$(command -v cmake 2>/dev/null || true)"
  if [[ -z "$_cmake" ]]; then
    pip_install cmake >/dev/null 2>&1 || true
    _cmake="$HOME/.local/bin/cmake"
  fi

  _tmpdir="$(mktemp -d)"
  git clone --depth 1 https://github.com/bartman/git-wip "$_tmpdir/git-wip" 2>/dev/null
  cd "$_tmpdir/git-wip"
  CC=gcc CXX=g++ "$_cmake" -G "Unix Makefiles" -S. -Bbuild -DCMAKE_INSTALL_PREFIX="$HOME/.local" -DCMAKE_BUILD_TYPE="Release" 2>/dev/null
  "$_cmake" --build build --config Release -j"$(nproc)" 2>/dev/null
  "$_cmake" --install build 2>/dev/null
  rm -rf "$_tmpdir"

  if _cmd_present git-wip; then
    success "git-wip installed from source"
  else
    err "git-wip installation failed"
    exit 1
  fi
fi