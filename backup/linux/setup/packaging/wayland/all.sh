# Wayland all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/awww.sh"
run_logged "$_PHASE_DIR/pypr.sh"
run_logged "$_PHASE_DIR/dunst.sh"
run_logged "$_PHASE_DIR/swaync.sh"
run_logged "$_PHASE_DIR/waybar.sh"
run_logged "$_PHASE_DIR/waybar-deps.sh"
run_logged "$_PHASE_DIR/hyprlock.sh"
run_logged "$_PHASE_DIR/hypridle.sh"
run_logged "$_PHASE_DIR/hyprsunset.sh"
run_logged "$_PHASE_DIR/hyprpolkitagent.sh"
run_logged "$_PHASE_DIR/wlogout.sh"
run_logged "$_PHASE_DIR/nwg-look.sh"
run_logged "$_PHASE_DIR/nwg-displays.sh"
run_logged "$_PHASE_DIR/wttrbar.sh"
run_logged "$_PHASE_DIR/swayosd.sh"
run_logged "$_PHASE_DIR/uwsm.sh"
run_logged "$_PHASE_DIR/xdg-desktop-portal-gtk.sh"
run_logged "$_PHASE_DIR/wf-recorder.sh"
run_logged "$_PHASE_DIR/kimageformats.sh"
run_logged "$_PHASE_DIR/misc/all.sh"
run_logged "$_PHASE_DIR/wayland-screenshots.sh"
run_logged "$_PHASE_DIR/wayland-clipboard.sh"
run_logged "$_PHASE_DIR/wtype.sh"
run_logged "$_PHASE_DIR/rofi.sh"
