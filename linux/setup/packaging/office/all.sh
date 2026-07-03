# Office all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/onlyoffice.sh"
run_logged "$_PHASE_DIR/obsidian.sh"
run_logged "$_PHASE_DIR/poppler.sh"
run_logged "$_PHASE_DIR/winapps-vm.sh"
