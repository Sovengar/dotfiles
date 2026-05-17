# Config all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/00-shell-default.sh"
run_logged "$_PHASE_DIR/05-brew-path.sh"
run_logged "$_PHASE_DIR/15-system-services.sh"
run_logged "$_PHASE_DIR/25-zen-browser-config.sh"
run_logged "$_PHASE_DIR/../fixes/50-audio-fix.sh"
