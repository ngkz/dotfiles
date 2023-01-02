#!@bash@/bin/bash
# XMonad-like workspace switching
set -euo pipefail
PATH=@coreutils@/bin:@jq@/bin:@sway@/bin:@gnused@/bin

workspace_want=$1
workspaces=$(swaymsg -t get_workspaces)

ws_num() {
    sed -En 's/([0-9]+)(:.*)?/\1/p' <<<"$1"
}

ws_output() {
    jq -r ".[]|select(.num == $(ws_num "$1")).output" <<<"$workspaces"
}

focused_workspace=$(jq -r '.[]|select(.focused).name' <<<"$workspaces")
active_output=$(ws_output "$focused_workspace")
workspace_want_output=$(ws_output "$workspace_want")

if [[ $(ws_num "$focused_workspace") = $(ws_num "$workspace_want") ]]; then
    exit 0
fi

swaymsg workspace number "$workspace_want"

if [[ -n $workspace_want_output ]] && [[ $workspace_want_output != $active_output ]]; then
    swaymsg move workspace to output "$active_output"
fi
