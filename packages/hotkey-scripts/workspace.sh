#!@bash@/bin/bash
# xmonad-style workspace switching
set -euo pipefail
PATH=@path@

workspace_want_name=$1
workspaces=$(swaymsg -t get_workspaces)

ws_num_from_name() {
    sed -En 's/([0-9]+)(:.*)?/\1/p' <<<"$1"
}

focused_workspace=$(jq '.[]|select(.focused)' <<<"$workspaces")
focused_workspace_num=$(jq -r '.num' <<<"$focused_workspace")
focused_output=$(jq -r '.output' <<<"$focused_workspace")
workspace_want_num=$(ws_num_from_name "$workspace_want_name")

if [[ $focused_workspace_num = $workspace_want_num ]]; then
    exit
fi

workspace_want=$(jq ".[]|select(.num == $workspace_want_num)" <<<"$workspaces")
workspace_want_output=$(jq -r ".output" <<<"$workspace_want")

if [[ -z $workspace_want_output ]] || [[ $workspace_want_output = $focused_output ]]; then
    # workspace is on focused output or does not exist: just switch
    swaymsg workspace number "$workspace_want_name"
    exit
fi

workspace_want_visible=$(jq ".visible" <<<"$workspace_want")

if [[ $workspace_want_visible != true ]]; then
    # workspace is on other output and hidden
    swaymsg workspace number "$workspace_want_name"
    swaymsg move workspace to output "$focused_output"
    exit
fi

# workspace is on other output and visible
# swap workspaces
swaymsg workspace number "$workspace_want_name"
swaymsg move workspace to output "$focused_output"
swaymsg workspace number "$focused_workspace_num"
swaymsg move workspace to output "$workspace_want_output"
swaymsg focus output "$focused_output"
