# Java tools all.sh

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/jd-gui.sh"
run_logged "$_PHASE_DIR/visualvm.sh"
