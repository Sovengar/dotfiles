#!/usr/bin/env bash
scrDir="$(dirname "$(realpath "$0")")"
source "$scrDir/globalcontrol.sh"
"$scrDir/keybinds.hint.py" --show-unbind > "${HYPR_STATE_HOME:-${XDG_STATE_HOME:-$HOME/.local/state}/hypr}/unbind.conf"
