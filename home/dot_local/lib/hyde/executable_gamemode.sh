#!/usr/bin/env bash
if ! source "$(which hyde-shell)"; then
    echo "[$0] :: Error: hyde-shell not found."
    echo "[$0] :: Is HyDE installed?"
    exit 1
fi

LOCK_FILE="${XDG_RUNTIME_DIR}/hyde/gamemode.lck"

if [ -f "$LOCK_FILE" ]; then
    previous_workflow=$(cat "$LOCK_FILE")
    set_conf "HYPR_WORKFLOW" "${previous_workflow:-default}"
    hyprctl reload config-only -q
    rm -f "$LOCK_FILE"
else
    mkdir -p "${XDG_RUNTIME_DIR}/hyde"
    [ -f "${XDG_STATE_HOME:-$HOME/.local/state}/hypr/workflow.conf" ] && source "${XDG_STATE_HOME:-$HOME/.local/state}/hypr/workflow.conf"
    printf "%s\n" "${HYPR_WORKFLOW:-default}" >"$LOCK_FILE"
    set_conf "HYPR_WORKFLOW" "gaming"
    hyprctl reload config-only -q
    touch "$LOCK_FILE"
fi
