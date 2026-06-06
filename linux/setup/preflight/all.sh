# Preflight all.sh

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/00-system-check.sh"
run_logged "$_PHASE_DIR/10-xdg-dirs.sh"
run_logged "$_PHASE_DIR/15-paru.sh"
run_logged "$_PHASE_DIR/17-chaotic-aur.sh"
run_logged "$_PHASE_DIR/20-brew.sh"
