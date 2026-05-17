# Shells all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/starship.sh"
run_logged "$_PHASE_DIR/gum.sh"
run_logged "$_PHASE_DIR/fastfetch.sh"
run_logged "$_PHASE_DIR/bash-completion.sh"
run_logged "$_PHASE_DIR/zsh.sh"
run_logged "$_PHASE_DIR/fish.sh"
run_logged "$_PHASE_DIR/nushell.sh"
run_logged "$_PHASE_DIR/bat.sh"
run_logged "$_PHASE_DIR/eza.sh"
