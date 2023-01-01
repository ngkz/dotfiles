#!@bash@/bin/bash
set -euo pipefail

PATH=@light@/bin:@libnotify@/bin:@coreutils@/bin

case "$1" in
up)
  light -A 5
  summary="Brightness up"
  ;;
down)
  light -U 5
  summary="Brightness down"
  ;;
esac

brightness=$(light -G | cut -d. -f1)
body="${brightness}%"
notify-send -a brightness -i display-brightness-symbolic -h "int:value:$brightness" -h string:synchronous:brightness -t 3000 -e "$summary" "$body"
