# npm globals all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/backlog-md.sh"
run_logged "$_PHASE_DIR/devcontainers-cli.sh"
run_logged "$_PHASE_DIR/tree-sitter-cli.sh"
run_logged "$_PHASE_DIR/kill-port.sh"
run_logged "$_PHASE_DIR/usebruno-cli.sh"
run_logged "$_PHASE_DIR/http-server.sh"
run_logged "$_PHASE_DIR/pm2.sh"
run_logged "$_PHASE_DIR/snyk.sh"
run_logged "$_PHASE_DIR/portless.sh"
