# Editors all.sh

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/neovim.sh"
run_logged "$_PHASE_DIR/vscode.sh"
