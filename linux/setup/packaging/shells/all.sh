# Shells all.sh

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/starship.sh"
run_logged "$_PHASE_DIR/gum.sh"
run_logged "$_PHASE_DIR/fastfetch.sh"
run_logged "$_PHASE_DIR/bash-completion.sh"
run_logged "$_PHASE_DIR/zsh.sh"
run_logged "$_PHASE_DIR/fish.sh"
run_logged "$_PHASE_DIR/nushell.sh"
