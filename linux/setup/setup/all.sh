# Setup all.sh — complex multi-step setups (icons, launchers, desktop entries, keybinds)

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/01-gemini-webapp.sh"
run_logged "$_PHASE_DIR/01-lazygit-scratchpad-tui.sh"
run_logged "$_PHASE_DIR/00-tui-generator-installer.sh"
run_logged "$_PHASE_DIR/02-lazydocker-tui.sh"
