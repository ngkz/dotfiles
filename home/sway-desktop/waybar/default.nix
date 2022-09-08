{ config, pkgs, lib, ... }:
let
  inherit (lib) hm;
  foot = "${pkgs.foot}/bin/foot";
  btop = "${pkgs.btop}/bin/btop";
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
  gnome-power-statistics = "${pkgs.gnome.gnome-power-manager}/bin/gnome-power-statistics";
  swaymsg = "${pkgs.sway}/bin/swaymsg";
  jq = "${pkgs.jq}/bin/jq";
  swaync-client = "${pkgs.ngkz.swaynotificationcenter-unstable}/bin/swaync-client";
  volume = (import ../hotkey.nix { inherit pkgs lib; }).volume;
  generateWaybarConfig = pkgs.writeShellScript "generate-waybar-config" ''
    set -euo pipefail

    hwmon_path=
    for path in /sys/class/hwmon/hwmon*/temp*_input; do 
        if [ "$(<$(dirname "$path")/name)" = coretemp ] && [ "$(<''${path%_*}_label)" = "Package id 0" ]; then
            hwmon_path=$path
            break
        fi
    done

    cat <<EOS >${config.xdg.configHome}/waybar/config
    [
      {
        "height": 24,
        "modules-left": [
          "custom/scratchpad",
          "sway/workspaces",
          "sway/mode"
        ],
        "modules-center": [
          "sway/window"
        ],
        "modules-right": [
          "tray",
          "custom/notification",
          $(if [ -n "$hwmon_path" ]; then echo '"temperature",'; fi)
          "cpu",
          "memory",
          "disk",
          "disk#nix",
          "disk#tmp",
          "pulseaudio",
          "battery",
          "battery#bat2",
          "clock"
        ],
        "custom/scratchpad": {
          "interval": 3,
          "return-type": "json",
          "exec": "${swaymsg} -t get_tree | ${jq} --unbuffered --compact-output '(recurse(.nodes[]) | select(.name == \\"__i3_scratch\\") | .focus) as \$scratch_ids | [..  | (.nodes? + .floating_nodes?) // empty | .[] | select(.id |IN(\$scratch_ids[]))] as \$scratch_nodes | if (\$scratch_nodes|length) > 0 then { text: \\"\\\\(\$scratch_nodes | length)\\", tooltip: \$scratch_nodes | map(\\"\\\\(.app_id // .window_properties.class) (\\\\(.id)): \\\\(.name)\\") | join(\\"\\\\n\\") } else empty end'",
          "format": "缾 {}",
          "on-click": "${swaymsg} 'scratchpad show'",
          "on-click-right": "${swaymsg} 'move scratchpad'"
        },
        "sway/workspaces": {
          "smooth-scrolling-threshold": 3,
        },
        "tray": {
          "icon-size": 16,
          "spacing": 5
        },
        "custom/notification": {
          "format": "{icon}",
          "format-icons": {
            "notification": " <span foreground='red'><sup></sup></span>",
            "none": "",
            "dnd-notification": " <span foreground='red'><sup></sup></span>",
            "dnd-none": "  "
          },
          "return-type": "json",
          "exec": "${swaync-client} -swb",
          "on-click": "${swaync-client} -t -sw",
          "on-click-right": "${swaync-client} -d -sw",
          "escape": true
        },
        "temperature": {
          "hwmon-path": "$hwmon_path",
          "critical-threshold": 80,
          "format": "",
          "format-critical": "{icon} {temperatureC}℃",
          "format-icons": ["", "", "", "", ""],
          "interval": 2,
        },
        "cpu": {
          "format": "",
          "format-load": " {max_frequency:0.1f}GHz {usage}% $(for i in $(seq $(nproc)); do echo -n "{icon$((i - 1))}"; done)",
          "format-icons": ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"],
          "interval": 2,
          "on-click": "${foot} -e ${btop}",
          "states": {
            "load": $((80 / $(nproc)))
          }
        },
        "memory": {
          "format": "",
          "format-critical": " {}%",
          "format-warning": " {}%",
          "interval": 10,
          "on-click": "${foot} -e ${btop}",
          "states": {
            "critical": 90,
            "warning": 80
          },
          "tooltip-format": "mem:  {used:0.2f} / {total:0.2f}GiB ({percentage}%)\nswap: {swapUsed:0.2f} / {swapTotal:0.2f}GiB ({swapPercentage}%)"
        },
        "disk": {
          "path": "/",
          "format": "",
          "format-warning": "{path} {percentage_used}%",
          "format-critical": "{path} {percentage_used}%",
          "states": {
            "critical": 90,
            "warning": 80,
          },
          "on-click": "${foot} -e ${btop}"
        },
        "disk#nix": {
          "path": "/nix",
          "format": "",
          "format-warning": "{path} {percentage_used}%",
          "format-critical": "{path} {percentage_used}%",
          "states": {
            "critical": 90,
            "warning": 80,
          },
          "on-click": "${foot} -e ${btop}"
        },
        "disk#tmp": {
          "path": "/tmp",
          "format": "",
          "format-warning": "{path} {percentage_used}%",
          "format-critical": "{path} {percentage_used}%",
          "states": {
            "critical": 90,
            "warning": 80,
          },
          "on-click": "${foot} -e ${btop}"
        },
        "pulseaudio": {
          "format": "{icon} {volume}%",
          "format-bluetooth": "{icon}{volume}%",
          "format-icons": {
            "car": "",
            "default": [
              "奄",
              "奔",
              "墳",
              ""
            ],
            "handsfree": "",
            "headphones": "",
            "headset": "",
            "phone": "",
            "portable": ""
          },
          "format-muted": "ﱝ",
          "on-click": "${pavucontrol}",
          "on-click-middle": "${volume} mute"
        },
        "battery": {
          "format": "{icon} {capacity}%",
          "format-charging": "{icon}↯ {time} {capacity}%",
          "format-discharging": "{icon} {power:.1f}W {time} {capacity}%",
          "format-icons": ["", "", "", "", "", "", "", "", "", "", ""],
          "format-plugged": "{icon}ﮣ\u200e{capacity}%",
          "format-time": "{H}:{M:02d}",
          "interval": 10,
          "on-click": "${gnome-power-statistics}",
          "states": {
            "critical": 15,
            "warning": 30
          }
        },
        "battery#bat2": {
          "bat": "BAT2"
        },
        "clock": {
          "format": " {:%R}",
          "format-alt": " {:%Y-%m-%d %a %H:%M}",
          "interval": 10,
          "locale": "C",
          "tooltip-format": "<big>{:%Y %B}</big>\n<tt>{calendar}</tt>"
        }
      }
    ]
    EOS
  '';

  #network = {
  #  interval = 2;
  #  format = "{icon}";
  #  format-ethernet = "{icon}";
  #  format-wifi = "{icon} {signalStrength}%";
  #  format-alt = "{icon} {ifname} {bandwidthUpBytes} {bandwidthDownBytes}";
  #  format-icons = {
  #    wifi = "直";
  #    ethernet = "";
  #    linked = "";
  #    disconnected = " ";
  #  };
  #  tooltip-format-ethernet = ''
  #    {ifname}
  #    {ipaddr}/{cidr}
  #    {bandwidthUpBits}({bandwidthUpBytes}) {bandwidthDownBits}({bandwidthDownBytes})'';
  #  tooltip-format-wifi = ''
  #    {ifname}
  #    SSID: {essid} {signalStrength}% {signaldBm}dBm {frequency}GHz
  #    {ipaddr}/{cidr}
  #    {bandwidthUpBits}({bandwidthUpBytes}) {bandwidthDownBits}({bandwidthDownBytes})'';
  #  tooltip-format-disconnected = "{ifname} (Disconnected)";
  #  on-click-right = networkmanager_dmenu;
  #};

  #bluetooth = {
  #  format = " ";
  #  format-disabled = " ";
  #  format-off = " ";
  #  format-connected = " ";
  #  format-connected-battery = " {device_battery_percentage}%";
  #  tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
  #  tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
  #  tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
  #  tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
  #};
in
{
  home.packages = [ pkgs.waybar ];

  home.activation.generate-waybar-config = hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${generateWaybarConfig}
  '';

  xdg.configFile."waybar/style.css".source = ./style.css;

  systemd.user.services.waybar = {
    Unit = {
      Description =
        "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
      Documentation = "https://github.com/Alexays/Waybar/wiki";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      X-Restart-Triggers = [
        "${config.xdg.configFile."waybar/style.css".source}"
        "${generateWaybarConfig}"
      ];
    };

    Service = {
      ExecStart = "${pkgs.waybar}/bin/waybar";
      Restart = "on-failure";
      KillMode = "process";
    };

    Install = { WantedBy = [ "sway-session.target" ]; };
  };
}