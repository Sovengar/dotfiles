# API and test tools all.sh

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/curl.sh"
run_logged "$_PHASE_DIR/ssh.sh"
run_logged "$_PHASE_DIR/hurl.sh"
run_logged "$_PHASE_DIR/bruno.sh"
run_logged "$_PHASE_DIR/soapui.sh"
run_logged "$_PHASE_DIR/jmeter.sh"
