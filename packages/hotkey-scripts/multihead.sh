#!@bash@/bin/bash
# XMonad-like monitor switching
set -euo pipefail
PATH=@jq@/bin:@sway@/bin

operation=$1
index=$2
monitor=$(swaymsg -t get_outputs | jq -r "sort_by(-.rect.y)|sort_by(.rect.x)[$index].name")

if [[ -z $monitor ]]; then
    exit 1
fi

case "$operation" in
    focus)
        swaymsg focus output "$monitor"
        ;;
    move)
        swaymsg move container to output "$monitor"
        ;;
esac
