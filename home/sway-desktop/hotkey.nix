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

  power-menu = pkgs.writeShellScript "power-menu" ''
    set -euo pipefail

    PATH=${lib.makeBinPath (with pkgs; [ coreutils wofi gawk systemd sway ])}

    op=$(wofi -p "Power" -i --dmenu --width 250 --height 210 --cache-file /dev/null <<EOS | awk '{ print tolower($2) }'
     Poweroff
    ‎ﰇ Reboot
     Suspend
     Hibernate
     Lock
     Logout
    EOS
    )
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
  '';

  screenshot = pkgs.writeShellScript "screenshot" ''
    # This script is based on grimshot:
    # https://github.com/swaywm/sway/blob/9e879242fd1f1230d34337984cca565d84b932bb/contrib/grimshot
    #
    # grimshot license:
    # Copyright (c) 2016-2017 Drew DeVault

    # Permission is hereby granted, free of charge, to any person obtaining a copy of
    # this software and associated documentation files (the "Software"), to deal in
    # the Software without restriction, including without limitation the rights to
    # use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
    # of the Software, and to permit persons to whom the Software is furnished to do
    # so, subject to the following conditions:

    # The above copyright notice and this permission notice shall be included in all
    # copies or substantial portions of the Software.

    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    # SOFTWARE.

    set -euo pipefail

    PATH=${lib.makeBinPath (with pkgs; [
      wofi coreutils grim slurp wl-clipboard xdg-user-dirs swappy sway jq libnotify imv
    ])}

    choice=$(wofi --dmenu -i -p "Select area" --cache-file /dev/null <<EOS
    All screens
    Active screen
    Active window
    Selection
    EOS
    )

    tmp=$(mktemp --suffix=.png)

    case "$choice" in
    "All screens")
      grim "$tmp"
      ;;
    "Active screen")
      output=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused)' | jq -r '.name')
      grim -o "$output" "$tmp"
      ;;
    "Active window")
      focused=$(swaymsg -t get_tree | jq -r 'recurse(.nodes[]?, .floating_nodes[]?) | select(.focused)')
      geom=$(echo "$focused" | jq -r '.rect | "\(.x),\(.y) \(.width)x\(.height)"')
      grim -g "$geom" "$tmp"
      ;;
    Selection)
      geom=$(slurp -d)
      grim -g "$geom" "$tmp"
      ;;
    esac

    choice=$(wofi --dmenu -i -p "Screenshot taken" --cache-file /dev/null <<EOS
    Save
    Copy
    Edit
    Discard
    EOS
    )

    case "$choice" in
    Save)
      out=$(xdg-user-dir PICTURES)/Screenshot_$(date +'%Y-%m-%d_%H:%M:%S.png')
      cp "$tmp" "$out"
      if [ "$(notify-send -u low -e -A "show=Show" "Screenshot taken" "$out")" = show ]; then
        imv "$out"
      fi
      ;;
    Copy)
      wl-copy --type image/png < "$tmp"
      notify-send -u low -e "Screenshot taken" "copied to clipboard"
      ;;
    Edit)
      swappy -f "$tmp"
      ;;
    esac

    rm -f "$tmp"
  '';
}
