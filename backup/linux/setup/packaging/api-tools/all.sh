# API and test tools all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/curl.sh"
run_logged "$_PHASE_DIR/ssh.sh"
run_logged "$_PHASE_DIR/hurl.sh"
run_logged "$_PHASE_DIR/bruno.sh"
run_logged "$_PHASE_DIR/soapui.sh"
run_logged "$_PHASE_DIR/jmeter.sh"
run_logged "$_PHASE_DIR/usebruno-cli.sh"
run_logged "$_PHASE_DIR/posting.sh"
