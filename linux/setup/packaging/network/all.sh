# Network all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/qbittorrent.sh"
run_logged "$_PHASE_DIR/hayase.sh"
run_logged "$_PHASE_DIR/jdownloader2.sh"
run_logged "$_PHASE_DIR/openssh.sh"
