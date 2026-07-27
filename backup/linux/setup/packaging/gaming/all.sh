# Gaming all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/steam.sh"
run_logged "$_PHASE_DIR/gamemode.sh"
run_logged "$_PHASE_DIR/mangohud.sh"
run_logged "$_PHASE_DIR/heroic.sh"
run_logged "$_PHASE_DIR/lutris.sh"
run_logged "$_PHASE_DIR/wine.sh"
run_logged "$_PHASE_DIR/proton.sh"
