{ pkgs, lib }:
{
  volume = pkgs.writeShellScript "volume" ''
    set -euo pipefail

    PATH=${lib.makeBinPath (with pkgs; [ pulseaudio libnotify gawk ])}

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
      body="''${volume}%"
      if [ $volume -ge 66 ]; then
          icon=audio-volume-high
      elif [ $volume -ge 33 ]; then
          icon=audio-volume-medium
      else
          icon=audio-volume-low
      fi
      vol_opt="-h int:value:$volume"
    fi

    notify-send -a volume -i "$icon" $vol_opt -h string:synchronous:volume -t 3000 -e "$summary" "$body"
    # TODO use sound-name hint after swaynotificationcenter#58
    paplay ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/audio-volume-change.oga
  '';

  micmute = pkgs.writeShellScript "micmute" ''
    set -euo pipefail

    PATH=${lib.makeBinPath (with pkgs; [ pulseaudio libnotify gawk ])}

    pactl set-source-mute @DEFAULT_SOURCE@ toggle
    if [ "$(LC_MESSAGES=C pactl get-source-mute @DEFAULT_SOURCE@)" = "Mute: yes" ]; then
      summary="Mute"
      body=
      icon=microphone-sensitivity-muted-symbolic
      vol_opt=
    else
      summary="Unmute"
      volume=$(LC_MESSAGES=C pactl get-source-volume @DEFAULT_SOURCE@ | awk '/Volume:/ { sub("%", "", $5); print $5 }')
      body="''${volume}%"
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
  '';

  brightness = pkgs.writeShellScript "brightness" ''
    set -euo pipefail

    PATH=${lib.makeBinPath (with pkgs; [ light libnotify coreutils ])}

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
    body="''${brightness}%"
    notify-send -a brightness -i display-brightness-symbolic -h "int:value:$brightness" -h string:synchronous:brightness -t 3000 -e "$summary" "$body"
  '';
}
