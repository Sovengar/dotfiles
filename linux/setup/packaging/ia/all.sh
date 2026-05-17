# IA agents all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/codex.sh"
run_logged "$_PHASE_DIR/opencode.sh"
run_logged "$_PHASE_DIR/engram.sh"
run_logged "$_PHASE_DIR/gga.sh"
run_logged "$_PHASE_DIR/google-antigravity.sh"
run_logged "$_PHASE_DIR/gh-copilot.sh"
run_logged "$_PHASE_DIR/termly.sh"
