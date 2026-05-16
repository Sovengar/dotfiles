# GitHub CLI extensions all.sh

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/gh-dash.sh"
run_logged "$_PHASE_DIR/gh-copilot.sh"
