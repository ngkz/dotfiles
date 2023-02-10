#!@bash@/bin/bash

set -euo pipefail

PATH=@path@

menu=" Poweroff
‎ﰇ Reboot
 Suspend
 Hibernate"

if [[ "$#" -lt 1 || "$1" != "greeter" ]]; then
    menu="$menu
 Lock
 Logout"
fi

op=$(wofi -p "Power" -i --dmenu --width 250 --height 210 --cache-file /dev/null <<<"$menu" | awk '{ print tolower($2) }')
case "$op" in
poweroff)
  systemctl poweroff -i
  ;;
reboot|suspend|hibernate)
  systemctl "$op"
  ;;
lock)
  loginctl lock-session
  ;;
logout)
  swaymsg exit
  ;;
esac
