#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Creating dev directory structure..."

mkdir -p "${HOME}/dev/projects"
mkdir -p "${HOME}/dev/personal"
mkdir -p "${HOME}/dev/learning"
mkdir -p "${HOME}/dev/work"

success "Dev directory structure created"
