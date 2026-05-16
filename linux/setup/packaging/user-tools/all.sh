# User tools all.sh

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/handy.sh"
run_logged "$_PHASE_DIR/webcord.sh"
run_logged "$_PHASE_DIR/obs-studio.sh"
