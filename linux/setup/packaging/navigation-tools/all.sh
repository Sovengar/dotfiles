# Navigation tools all.sh

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/zoxide.sh"
run_logged "$_PHASE_DIR/yazi.sh"
run_logged "$_PHASE_DIR/broot.sh"
