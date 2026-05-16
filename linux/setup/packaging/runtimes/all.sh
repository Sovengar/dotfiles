# Runtimes and environment managers all.sh

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/mise.sh"
run_logged "$_PHASE_DIR/java.sh"
run_logged "$_PHASE_DIR/node.sh"
run_logged "$_PHASE_DIR/go.sh"
run_logged "$_PHASE_DIR/rust-cargo.sh"
