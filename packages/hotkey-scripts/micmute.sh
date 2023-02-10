#!@bash@/bin/bash
set -euo pipefail

PATH=@path@

pactl set-source-mute @DEFAULT_SOURCE@ toggle
if [ "$(LC_MESSAGES=C pactl get-source-mute @DEFAULT_SOURCE@)" = "Mute: yes" ]; then
  summary="Mute"
  body=
  icon=microphone-sensitivity-muted-symbolic
  vol_opt=
else
  summary="Unmute"
  volume=$(LC_MESSAGES=C pactl get-source-volume @DEFAULT_SOURCE@ | awk '/Volume:/ { sub("%", "", $5); print $5 }')
  body="${volume}%"
  if [ $volume -ge 66 ]; then
      icon=microphone-sensitivity-high-symbolic
  elif [ $volume -ge 33 ]; then
      icon=microphone-sensitivity-medium-symbolic
  else
      icon=microphone-sensitivity-low-symbolic
  fi
  vol_opt="-h int:value:$volume"
fi

notify-send -a volume -i "$icon" $vol_opt -h string:synchronous:volume -t 3000 -e "$summary" "$body"
