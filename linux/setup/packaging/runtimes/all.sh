# Runtimes and environment managers all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/mise.sh"
run_logged "$_PHASE_DIR/java.sh"
run_logged "$_PHASE_DIR/node.sh"
run_logged "$_PHASE_DIR/go.sh"
run_logged "$_PHASE_DIR/rust-cargo.sh"
run_logged "$_PHASE_DIR/http-server.sh"
run_logged "$_PHASE_DIR/pm2.sh"
