#!/usr/bin/env bash
if ! source "$(which hyde-shell)"; then
    echo "[$0] :: Error: hyde-shell not found."
    echo "[$0] :: Is HyDE installed?"
    exit 1
fi

# Source argparse.sh for argument parsing
source "${LIB_DIR}/hyde/shutils/argparse.sh"

confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
workflows_dir="$confDir/hypr/workflows"
if [ ! -d "$workflows_dir" ]; then
    notify-send -i "preferences-desktop-display" "Error" "Workflows directory does not exist at $workflows_dir"
    exit 1
fi

workflow_file() {
    local workflow_name="$1"
    if [ -f "$workflows_dir/$workflow_name.lua" ]; then
        printf "%s\n" "$workflows_dir/$workflow_name.lua"
    fi
}

workflow_name_from_path() {
    basename "$1" | sed 's/\.[^.]*$//'
}

workflow_meta() {
    local field="$1"
    local path="$2"

    awk -v key="@workflow_${field}" '$0 ~ "^--[[:space:]]*" key "[[:space:]]+" { sub("^--[[:space:]]*" key "[[:space:]]+", ""); print; exit }' "$path"
}

fn_select() {
    default_path=$(workflow_file "default")
    default_icon=$(workflow_meta "icon" "$default_path")
    default_icon=${default_icon:0:1}
    workflow_list="$default_icon\t default"
    while IFS= read -r workflow_path; do
        workflow_name=$(workflow_name_from_path "$workflow_path" | xargs)
        [ "$workflow_name" = "default" ] && continue
        workflow_icon=$(workflow_meta "icon" "$workflow_path")
        workflow_icon=${workflow_icon:0:1}
        workflow_list="$workflow_list\n$workflow_icon\t $workflow_name"
    done < <(find -L "$workflows_dir" -type f -name "*.lua" 2>/dev/null | sort)
    font_scale="$ROFI_WORKFLOW_SCALE"
    [[ $font_scale =~ ^[0-9]+$ ]] || font_scale=${ROFI_SCALE:-10}
    font_name=${ROFI_WORKFLOW_FONT:-$ROFI_FONT}
    font_name=${font_name:-$(get_hyprConf "MENU_FONT")}
    font_name=${font_name:-$(get_hyprConf "FONT")}
    font_override="* {font: \"${font_name:-\"JetBrainsMono Nerd Font\"} $font_scale\";}"
    hypr_border=${hypr_border:-"$(hyprctl -j getoption decoration:rounding | jq '.int')"}
    wind_border=$((hypr_border * 3 / 2))
    elem_border=$((hypr_border == 0 ? 5 : hypr_border))
    hypr_width=${hypr_width:-"$(hyprctl -j getoption general:border_size | jq '.int')"}
    r_override="window{border:${hypr_width}px;border-radius:${wind_border}px;} wallbox{border-radius:${elem_border}px;} element{border-radius:${elem_border}px;}"
    rofi_select="${HYPR_WORKFLOW/default/default}"
    selected_workflow=$(echo -e "$workflow_list" | rofi -dmenu -i -select "$rofi_select" \
        -p "Select workflow" \
        -theme-str 'entry { placeholder: "💼 Select workflow..."; }' \
        -theme-str "$font_override" \
        -theme-str "$r_override" \
        -theme-str "$(get_rofi_pos)" \
        -theme "clipboard")
    if [ -z "$selected_workflow" ]; then
        exit 0
    fi
    selected_workflow=$(awk -F'\t' '{print $2}' <<<"$selected_workflow" | xargs)
    set_conf "HYPR_WORKFLOW" "$selected_workflow"
    fn_update
}
get_info() {
    [ -f "${XDG_STATE_HOME:-$HOME/.local/state}/hypr/workflow.conf" ] && source "${XDG_STATE_HOME:-$HOME/.local/state}/hypr/workflow.conf"
    [ -f "${WAYBAR_STATE_FILE:-${XDG_STATE_HOME:-$HOME/.local/state}/waybar/state}" ] && source "${WAYBAR_STATE_FILE:-${XDG_STATE_HOME:-$HOME/.local/state}/waybar/state}"
    current_workflow=${HYPR_WORKFLOW:-"default"}
    current_path=$(workflow_file "$current_workflow")
    current_icon=$(workflow_meta "icon" "$current_path")
    current_icon=${current_icon:0:1}
    current_description=$(workflow_meta "description" "$current_path")
    current_description=${current_description:-"No description available"}
    export current_icon current_workflow current_description
}
fn_update() {
    get_info
    hyprctl reload config-only -q >/dev/null 2>&1 || true
    printf "%s %s: %s\n" "$current_icon" "$current_workflow" "$current_description"
    notify-send -r 9 -i "preferences-desktop-display" "Workflow: $current_icon $current_workflow" "$current_description"
}
handle_waybar() {
    get_info
    text="$current_icon"
    tooltip="Mode: $current_icon $current_workflow \n$current_description"
    class="custom-workflows"
    echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\", \"class\": \"$class\"}"
}

# Initialize argparse
argparse_init "$@"

# Set program name and header
argparse_program "hyde-shell workflows"
argparse_header "HyDE Workflow Selector"

# Define arguments
argparse "--set" "WORKFLOW_NAME" "Set the given workflow" "parameter"
argparse "--select,-S" "" "Select a workflow from the available options"
argparse "--waybar" "" "Get workflow info for Waybar"
argparse "--help,-h" "" "Show this help message"

# Finalize parsing
argparse_finalize

# Handle the parsed arguments
[[ -z $ARGPARSE_ACTION ]] && ARGPARSE_ACTION=help

case "$ARGPARSE_ACTION" in
select)
    fn_select
    if pgrep -x waybar >/dev/null; then
        pkill -RTMIN+7 waybar
    fi
    ;;
set)
    if [ -z "$WORKFLOW_NAME" ]; then
        echo "Error: --set requires a workflow name"
        exit 1
    fi
    set_conf "HYPR_WORKFLOW" "$WORKFLOW_NAME"
    fn_update
    if pgrep -x waybar >/dev/null; then
        pkill -RTMIN+7 waybar
    fi
    ;;
waybar) handle_waybar ;;
help) argparse_help ;;
*) argparse_help ;;
esac
