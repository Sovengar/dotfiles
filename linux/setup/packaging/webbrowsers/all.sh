# Web browsers all.sh

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/zen-browser.sh"
run_logged "$_PHASE_DIR/firefox.sh"
