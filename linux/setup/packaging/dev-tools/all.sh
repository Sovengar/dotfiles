# Developer tools all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/snyk.sh"
run_logged "$_PHASE_DIR/kill-port.sh"
run_logged "$_PHASE_DIR/portless.sh"
run_logged "$_PHASE_DIR/http-server.sh"
run_logged "$_PHASE_DIR/pm2.sh"
run_logged "$_PHASE_DIR/jd-gui.sh"
run_logged "$_PHASE_DIR/visualvm.sh"
run_logged "$_PHASE_DIR/jqp.sh"
run_logged "$_PHASE_DIR/dust.sh"
run_logged "$_PHASE_DIR/sd.sh"
run_logged "$_PHASE_DIR/dog.sh"
run_logged "$_PHASE_DIR/xh.sh"
run_logged "$_PHASE_DIR/atuin.sh"
run_logged "$_PHASE_DIR/lazynpm.sh"
run_logged "$_PHASE_DIR/depot-tools.sh"
