# Config all.sh

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/00-shell-default.sh"
run_logged "$_PHASE_DIR/05-brew-path.sh"
run_logged "$_PHASE_DIR/10-keyboard.sh"
run_logged "$_PHASE_DIR/15-system-services.sh"
run_logged "$_PHASE_DIR/20-keepassxc-autostart.sh"
run_logged "$_PHASE_DIR/25-zen-browser-config.sh"
run_logged "$_PHASE_DIR/30-gdrive.sh"
run_logged "$_PHASE_DIR/40-onedrive.sh"
run_logged "$_PHASE_DIR/50-audio-fix.sh"
run_logged "$_PHASE_DIR/60-pyprland.sh"
