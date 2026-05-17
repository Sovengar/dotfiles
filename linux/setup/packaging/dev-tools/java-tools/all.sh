# Java tools all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../../helpers/all.sh"
fi

run_logged "$(dirname "${BASH_SOURCE[0]}")/jd-gui.sh"
run_logged "$(dirname "${BASH_SOURCE[0]}")/visualvm.sh"
