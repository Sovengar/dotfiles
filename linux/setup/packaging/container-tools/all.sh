# Container tools all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/docker.sh"
run_logged "$_PHASE_DIR/lazydocker.sh"
run_logged "$_PHASE_DIR/podman-cli.sh"
run_logged "$_PHASE_DIR/podman-desktop.sh"
run_logged "$_PHASE_DIR/devcontainers-cli.sh"
run_logged "$_PHASE_DIR/testcontainers-desktop.sh"
