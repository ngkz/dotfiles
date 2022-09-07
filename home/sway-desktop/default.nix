{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkOptionDefault types concatStringsSep;

  xdg-user-dir = "${pkgs.xdg-user-dirs}/bin/xdg-user-dir";
  grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";
  wlogout = "${pkgs.wlogout}/bin/wlogout";
  i3-wk-switch = "${pkgs.i3-wk-switch}/bin/i3-wk-switch";
  swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
  swaymsg = "${pkgs.sway-unwrapped}/bin/swaymsg";
  pgrep = "${pkgs.procps}/bin/pgrep";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  cat = "${pkgs.coreutils}/bin/cat";
  swaync-client = "${pkgs.ngkz.swaynotificationcenter-unstable}/bin/swaync-client";
  hotkey = import ./hotkey.nix { inherit pkgs lib; };
  sway = config.wayland.windowManager.sway.config;
  mod = sway.modifier;
  inherit (sway) left right up down;
  cfg = config.home.sway-desktop;
in
{
  options.home.sway-desktop = {
    internal = mkOption {
      type = types.nullOr types.str;
      description = "Name of internal LCD output";
      default = null;
    };
  };

  imports = [
    ./waybar
  ];

  config = {
    # Sway configuration
    wayland.windowManager.sway = {
      enable = true;
      systemdIntegration = false; # XXX workaround for home-manager #2806
      package = null; # use system sway package
      config = {
        modifier = "Mod4"; # Super
        terminal = "foot";
        fonts = {
          names = [ "Sans-Serif" ];
          style = "Regular";
          size = 10.0;
        };
        bars = [ ];
        gaps.smartBorders = "on";
        colors.focused = {
          border = "#e02334";
          background = "#a0000e";
          text = "#ffffff";
          indicator = "#b5bd68";
          childBorder = "#e02334";
        };
        keybindings = mkOptionDefault {
          # xmonad-style workspace switching + additional workspace
          "${mod}+1" = "exec ${i3-wk-switch} 1";
          "${mod}+2" = "exec ${i3-wk-switch} 2";
          "${mod}+3" = "exec ${i3-wk-switch} 3";
          "${mod}+4" = "exec ${i3-wk-switch} 4";
          "${mod}+5" = "exec ${i3-wk-switch} 5";
          "${mod}+6" = "exec ${i3-wk-switch} 6";
          "${mod}+7" = "exec ${i3-wk-switch} 7";
          "${mod}+8" = "exec ${i3-wk-switch} 8";
          "${mod}+9" = "exec ${i3-wk-switch} 9";
          "${mod}+0" = "exec ${i3-wk-switch} 10";
          "${mod}+minus" = "exec ${i3-wk-switch} 11";
          "${mod}+asciicircum" = "exec ${i3-wk-switch} 12";
          "${mod}+backslash" = "exec ${i3-wk-switch} 13";
          "${mod}+BackSpace" = "exec ${i3-wk-switch} 14";

          "${mod}+Shift+minus" = "move container to workspace number 11";
          "${mod}+Shift+asciicircum" = "move container to workspace number 12";
          "${mod}+Shift+backslash" = "move container to workspace number 13";
          "${mod}+Shift+BackSpace" = "move container to workspace number 14";

          # quick resize
          "${mod}+Control+${left}" = "resize shrink width 40px";
          "${mod}+Control+${down}" = "resize grow height 40px";
          "${mod}+Control+${up}" = "resize shrink height 40px";
          "${mod}+Control+${right}" = "resize grow width 40px";

          "${mod}+Tab" = "workspace back_and_forth";
          "${mod}+Shift+a" = "focus child";
          "${mod}+q" = "split none";

          # new tab container
          "${mod}+t" = "exec 'swaymsg splith && swaymsg layout tabbed'";

          #"${mod}+d" = "";
          "${mod}+Shift+Return" = "exec ${sway.terminal} --app-id=foot-floating"; # spawn flaoting terminal
          "${mod}+Shift+e" = "exec ${wlogout}";
          "${mod}+Escape" = "exec loginctl lock-session";

          # screenshot
          "Print" = "exec ${grimshot} --notify save screen $(${xdg-user-dir} PICTURES)/Screenshot_$(date +'%Y-%m-%d_%H:%M:%S.png')";
          "Alt+Print" = "exec ${grimshot} --notify save window $(${xdg-user-dir} PICTURES)/Screenshot_$(date +'%Y-%m-%d_%H:%M:%S.png')";
          "Control+Print" = "exec ${grimshot} --notify save area $(${xdg-user-dir} PICTURES)/Screenshot_$(date +'%Y-%m-%d_%H:%M:%S.png')";

          "Shift+Print" = "exec ${grimshot} --notify copy screen";
          "Shift+Alt+Print" = "exec ${grimshot} --notify copy window";
          "Shift+Control+Print" = "exec ${grimshot} --notify copy area";

          # Move the currently focused window to the scratchpad
          "${mod}+Shift+Zenkaku_Hankaku" = "move scratchpad";
          # Show the next scratchpad window or hide the focused scratchpad window.
          # If there are multiple scratchpad windows, this command cycles through them.
          "${mod}+Zenkaku_Hankaku" = "scratchpad show";

          # media keys
          "XF86AudioRaiseVolume" = "exec ${hotkey.volume} up";
          "XF86AudioLowerVolume" = "exec ${hotkey.volume} down";
          "XF86AudioMute" = "exec ${hotkey.volume} mute";
          "XF86AudioMicMute" = "exec ${hotkey.micmute}";
          "XF86MonBrightnessUp" = "exec ${hotkey.brightness} up";
          "XF86MonBrightnessDown" = "exec ${hotkey.brightness} down";

          # notification
          "${mod}+Shift+n" = "exec ${swaync-client} --toggle-panel --skip-wait";
          "${mod}+n" = "exec ${swaync-client} --close-latest --skip-wait";
        };
        input =
          let
            keyboard = {
              xkb_layout = "jp";
              repeat_delay = "350";
              repeat_rate = "30";
            };
          in
          {
            "type:keyboard" = keyboard;
            "type:touchpad" = {
              click_method = "clickfinger";
              middle_emulation = "enabled";
              pointer_accel = "1";
              tap = "enabled";
            };
            "6127:24647:Lenovo_ThinkPad_Compact_USB_Keyboard_with_TrackPoint" = {
              pointer_accel = "0.4";
            } // keyboard; # workaround for issue #5943
          };
        output = {
          "*" = {
            bg = "${./wallpapers/DSC02942.JPG} fill";
          };
        };
        seat = {
          "*" = {
            xcursor_theme = "Adwaita";
          };
        };
        window.commands = [
          {
            # mark xwayland windows
            criteria = { shell = "xwayland$"; };
            command = "title_format \"𝕏  %title\"";
          }
          {
            criteria = { app_id = "foot-floating$"; };
            command = "floating enable";
          }
        ];
      };
      extraConfig =
        (if cfg.internal != null then ''
          # clamshell mode
          bindswitch --reload --locked lid:on output ${cfg.internal} disable
          bindswitch --reload --locked lid:off output ${cfg.internal} enable
        '' else "") + ''
          # XXX workaround for home-manager #2806
          include ${pkgs.ngkz.sway-systemd}/etc/sway/config.d/10-systemd-session.conf
        '';
    };

    services.swayidle = {
      enable = true;
      events = [
        {
          event = "lock";
          command = concatStringsSep " " [
            "LC_TIME=C"
            swaylock
            "--daemonize"
            "--indicator"
            "--clock"
            "--datestr \"%%Y-%%m-%%d %%a\""
            "--image ${./wallpapers/DSC01320.JPG}"
            "--indicator-radius 200"
            "--indicator-thickness 10"
            "--ring-color c5c8c6"
            "--ring-ver-color d00029"
            "--ring-wrong-color ffb039"
            "--ring-clear-color 8abeb7"
            "--inside-color 00000088"
            "--inside-ver-color 00000088"
            "--inside-wrong-color 00000088"
            "--inside-clear-color 00000088"
            "--line-color 00000000"
            "--separator-color 00000000"
            "--line-clear-color 00000000"
            "--line-ver-color 00000000"
            "--line-wrong-color 00000000"
            "--key-hl-color d00029"
            "--text-color c5c8c6"
            "--text-ver-color d00029"
            "--text-caps-lock-color d00029"
            "--text-wrong-color ffb039"
            "--text-clear-color 8abeb7"
            "--font 'IBM Plex Mono'"
          ];
        }
        {
          event = "before-sleep";
          command = "${loginctl} lock-session";
        }
      ];
      timeouts = [
        {
          timeout = 10;
          command = "${pgrep} -x swaylock >/dev/null && ${swaymsg} 'output * dpms off'";
          resumeCommand = "${swaymsg} 'output * dpms on'";
        }
        {
          timeout = 300;
          command = "${swaymsg} 'output * dpms off'";
          resumeCommand = "${swaymsg} 'output * dpms on'";
        }
        {
          timeout = 310;
          command = "${loginctl} lock-session";
        }
        {
          timeout = 600;
          command = "[ $(${cat} /sys/class/power_supply/AC/online) = 0 ] && ${systemctl} suspend";
        }
      ];
    };

    # XXX Remove after home-manager #2811 merge
    systemd.user.services.swayidle.Service.Environment = [
      "PATH=${pkgs.bash}/bin"
    ];

    services.gammastep = {
      enable = true;
      latitude = "36.3418";
      longitude = "140.4467";
      temperature = {
        day = 6500;
        night = 5000;
      };
    };

    #swaync
    xdg.configFile."swaync/config.json".text = builtins.toJSON {
      scripts = {
        sound = {
          app-name = "^(?!volume|brightness).*$";
          summary = "^(?!Command completed in ).*$";
          exec = "${pkgs.pulseaudio}/bin/paplay ${./airplane-announcement.ogg}";
        };
      };
    };

    home.packages = with pkgs; [
      # XXX workaround for home-manager #2806
      ngkz.sway-systemd

      ngkz.swaynotificationcenter-unstable
      swaylock-effects
    ];
  };
}
