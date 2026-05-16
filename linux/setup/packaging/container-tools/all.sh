# Container tools all.sh

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/docker.sh"
run_logged "$_PHASE_DIR/lazydocker.sh"
run_logged "$_PHASE_DIR/podman-cli.sh"
run_logged "$_PHASE_DIR/podman-desktop.sh"
run_logged "$_PHASE_DIR/datree.sh"
