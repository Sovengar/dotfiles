# AI agents all.sh

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/codex.sh"
run_logged "$_PHASE_DIR/opencode.sh"
run_logged "$_PHASE_DIR/engram.sh"
run_logged "$_PHASE_DIR/gga.sh"
run_logged "$_PHASE_DIR/google-antigravity.sh"
