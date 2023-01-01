#!@bash@/bin/bash
# Based on https://gist.github.com/lbonn/89d064cde963cfbacabd77e0d3801398?permalink_comment_id=4181591#gistcomment-4181591

PATH=@wofi@/bin:@sway@/bin:@jq@/bin:@gnused@/bin

row=$(swaymsg -t get_tree | jq  -r '
    ..
    | objects
    | select(.type == "workspace") as $ws
    | ..
    | objects
    | select(has("app_id"))
    | (if .focused == true then "*" else " " end) as $asterisk
    | "[\($ws.name)]\t\($asterisk) \(.name) <small>\(.app_id)</small> <!-- \(.id) -->"' \
| sed 's/&/&amp;/g' \
| wofi --dmenu --allow-markup -k /dev/null)

if [ ! -z "$row" ]
then
    winid=$(echo "$row" | sed 's/.*<!-- \([0-9]*\) -->.*/\1/')
    swaymsg "[con_id=$winid] focus"
fi
