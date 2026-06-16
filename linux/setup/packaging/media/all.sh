# Media all.sh

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

_PHASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_PHASE_DIR/spicetify-cli.sh"
run_logged "$_PHASE_DIR/spotify-adblock.sh"
run_logged "$_PHASE_DIR/spotify.sh"
run_logged "$_PHASE_DIR/zbar.sh"
run_logged "$_PHASE_DIR/webcamize.sh"
run_logged "$_PHASE_DIR/ffmpeg.sh"
run_logged "$_PHASE_DIR/imv.sh"
run_logged "$_PHASE_DIR/resvg.sh"
