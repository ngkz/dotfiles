#!@bash@/bin/bash
set -euo pipefail

export PATH=@path@

is_mute() {
  if [ "$(LC_MESSAGES=C pactl get-sink-mute @DEFAULT_SINK@)" = "Mute: yes" ]; then
    return 0
  else
    return 1
  fi
}

case "$1" in
up)
  summary="Volume up"
  pactl set-sink-mute @DEFAULT_SINK@ 0
  pactl set-sink-volume @DEFAULT_SINK@ +5%
  ;;
down)
  summary="Volume down"
  pactl set-sink-mute @DEFAULT_SINK@ 0
  pactl set-sink-volume @DEFAULT_SINK@ -5%
  ;;
mute)
  pactl set-sink-mute @DEFAULT_SINK@ toggle
  if is_mute; then
    summary=Mute
  else
    summary=Unmute
  fi
esac

if is_mute; then
  icon=audio-volume-muted
  body=
  vol_opt=
else
  volume=$(LC_MESSAGES=C pactl get-sink-volume @DEFAULT_SINK@ | awk '/Volume:/ { sub("%", "", $5); print $5 }')
  body="${volume}%"
  if [ "$volume" -ge 66 ]; then
      icon=audio-volume-high
  elif [ "$volume" -ge 33 ]; then
      icon=audio-volume-medium
  else
      icon=audio-volume-low
  fi
  vol_opt="-h int:value:$volume"
fi

notify-send -a volume -i "$icon" $vol_opt -h string:synchronous:volume -t 3000 -e "$summary" "$body"
# TODO use sound-name hint after swaynotificationcenter#58
canberra-gtk-play -i audio-volume-change
