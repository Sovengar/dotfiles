# Assets all.sh — icons, cursors, and other non-GTK desktop assets

_ASSETS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_logged "$_ASSETS_DIR/04-cursors.sh"
run_logged "$_ASSETS_DIR/05-icons.sh"
