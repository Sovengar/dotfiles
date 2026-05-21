#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Installing depot_tools..."

DEPOT_TOOLS_DIR="$HOME/Applications/depot_tools"
REPO_URL="https://chromium.googlesource.com/chromium/tools/depot_tools.git"

if [[ -x "$DEPOT_TOOLS_DIR/gclient" && -x "$DEPOT_TOOLS_DIR/fetch" ]]; then
  success "depot_tools already installed"
  return 0 2>/dev/null || exit 0
fi

if ! _cmd_present git; then
  err "git is required to install depot_tools"
  exit 1
fi

mkdir -p "$(dirname "$DEPOT_TOOLS_DIR")"

if [[ -d "$DEPOT_TOOLS_DIR/.git" ]]; then
  git -C "$DEPOT_TOOLS_DIR" pull --ff-only
elif [[ -e "$DEPOT_TOOLS_DIR" ]]; then
  err "$DEPOT_TOOLS_DIR exists but is not a git checkout"
  exit 1
else
  git clone "$REPO_URL" "$DEPOT_TOOLS_DIR"
fi

success "depot_tools installed to $DEPOT_TOOLS_DIR"
