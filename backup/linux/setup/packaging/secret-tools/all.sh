# Secret manager all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/keepassxc.sh"
run_logged "$_PHASE_DIR/age.sh"
run_logged "$_PHASE_DIR/sops.sh"
run_logged "$_PHASE_DIR/doppler.sh"
