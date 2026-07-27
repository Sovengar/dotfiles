#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/zsh-autosuggestions.sh"
run_logged "$_PHASE_DIR/zsh-syntax-highlighting.sh"
run_logged "$_PHASE_DIR/zsh-completions.sh"
run_logged "$_PHASE_DIR/zsh-history-substring-search.sh"
run_logged "$_PHASE_DIR/oh-my-zsh-git.sh"
run_logged "$_PHASE_DIR/zsh-theme-powerlevel10k.sh"
