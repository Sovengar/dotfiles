# Navigation tools all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/zoxide.sh"
run_logged "$_PHASE_DIR/cdx.sh"
run_logged "$_PHASE_DIR/broot.sh"
run_logged "$_PHASE_DIR/kill-port.sh"
run_logged "$_PHASE_DIR/portless.sh"
run_logged "$_PHASE_DIR/snyk.sh"
run_logged "$_PHASE_DIR/backlog-md.sh"
