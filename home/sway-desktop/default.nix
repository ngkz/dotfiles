{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkOptionDefault types concatStringsSep;

  swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
  swaymsg = "${pkgs.sway-unwrapped}/bin/swaymsg";
  pgrep = "${pkgs.procps}/bin/pgrep";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  cat = "${pkgs.coreutils}/bin/cat";
  swaync-client = "${pkgs.ngkz.swaynotificationcenter-unstable}/bin/swaync-client";
  foot = "${pkgs.foot}/bin/foot";
  wofi = "${pkgs.wofi}/bin/wofi";
  hotkey = import ./hotkey.nix { inherit pkgs lib; };
  autoname-workspaces = pkgs.writers.writePython3 "autoname-workspaces.py"
    { libraries = [ pkgs.python3Packages.i3ipc ]; } ./autoname-workspaces.py;
  sway = config.wayland.windowManager.sway.config;
  mod = sway.modifier;
  inherit (sway) left right up down;
  output-left = "u";
  output-down = "i";
  output-up = "o";
  output-right = "p";
  ws10 = "10:0";
  ws11 = "11:-";
  ws12 = "12:^";
  ws13 = "13:∖";
  ws14 = "14:←";
in
{
  imports = [
    ./waybar
  ];

  # Sway configuration
  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = false; # XXX workaround for home-manager #2806
    package = null; # use system sway package
    config = {
      modifier = "Mod4"; # Super
      terminal = foot;
      menu = "${wofi} --show drun --allow-images --columns 3 --lines 15 --cache-file ${config.xdg.cacheHome}/wofi/drun --insensitive";
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
        # additional workspaces
        "${mod}+0" = "workspace number ${ws10}";
        "${mod}+minus" = "workspace number ${ws11}";
        "${mod}+asciicircum" = "workspace number ${ws12}";
        "${mod}+backslash" = "workspace number ${ws13}";
        "${mod}+BackSpace" = "workspace number ${ws14}";

        "${mod}+Shift+0" = "move container to workspace number ${ws10}";
        "${mod}+Shift+minus" = "move container to workspace number ${ws11}";
        "${mod}+Shift+asciicircum" = "move container to workspace number ${ws12}";
        "${mod}+Shift+backslash" = "move container to workspace number ${ws13}";
        "${mod}+Shift+BackSpace" = "move container to workspace number ${ws14}";

        # switch monitor
        "${mod}+${output-left}" = "focus output left";
        "${mod}+${output-down}" = "focus output down";
        "${mod}+${output-up}" = "focus output up";
        "${mod}+${output-right}" = "focus output right";

        # move container to another monitor
        "${mod}+Shift+${output-left}" = "move container to output left";
        "${mod}+Shift+${output-down}" = "move container to output down";
        "${mod}+Shift+${output-up}" = "move container to output up";
        "${mod}+Shift+${output-right}" = "move container to output right";

        # move workspace to another monitor
        "${mod}+Control+${output-left}" = "move workspace to output left";
        "${mod}+Control+${output-down}" = "move workspace to output down";
        "${mod}+Control+${output-up}" = "move workspace to output up";
        "${mod}+Control+${output-right}" = "move workspace to output right";

        # quick resize
        "${mod}+Control+${left}" = "resize shrink width 40px";
        "${mod}+Control+${down}" = "resize grow height 40px";
        "${mod}+Control+${up}" = "resize shrink height 40px";
        "${mod}+Control+${right}" = "resize grow width 40px";

        "${mod}+Tab" = "exec ${hotkey.switch-window}";
        "${mod}+Alt+Tab" = "workspace back_and_forth";
        "${mod}+Shift+a" = "focus child";
        "${mod}+q" = "split none";

        # new tab container
        "${mod}+t" = "exec 'swaymsg splith && swaymsg layout tabbed'";

        #"${mod}+d" = "";
        "${mod}+Shift+Return" = "exec ${sway.terminal} --app-id=foot-floating"; # spawn flaoting terminal
        "${mod}+Shift+e" = "exec ${hotkey.power-menu}";
        "${mod}+Escape" = "exec loginctl lock-session";

        # screenshot
        "Print" = "exec ${hotkey.screenshot}";

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
          # internal TrackPoint
          "2:10:TPPS/2_Elan_TrackPoint" = {
            pointer_accel = "1.0";
          };
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
        {
          criteria = {
            app_id = "org.keepassxc.KeePassXC$";
            title = "KeePassXC - ブラウザーのアクセス要求";
          };
          command = "floating enable";
        }
      ];
    };
    extraConfig = ''
      # clamshell mode
      bindswitch --reload --locked lid:on output LVDS-1 disable, output eDP-1 disable
      bindswitch --reload --locked lid:off output LVDS-1 enable, output eDP-1 enable

      # XXX workaround for home-manager #2806
      include ${pkgs.ngkz.sway-systemd}/etc/sway/config.d/10-systemd-session.conf

      # initial workspace
      workspace number 1
    '';
  };

  # override xdg-desktop-portal-wlr.service
  # After=graphical-session.target causes dependency loop
  # XXX xdg-desktop-portal-wlr #238
  systemd.user.services.xdg-desktop-portal-wlr = {
    Unit = {
      Description = "Portal service (wlroots implementation)";
      PartOf = [ "sway-session.target" ];
    };

    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.impl.portal.desktop.wlr";
      ExecStart = "${pkgs.xdg-desktop-portal-wlr}/bin/xdg-desktop-portal-wlr";
      Restart = "on-failure";
    };
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

  services.kanshi = {
    enable = true;
    profiles = {
      peregrine-undocked = {
        outputs = [{
          criteria = "Chimei Innolux Corporation 0x14F3 0x00000000";
          scale = 1.0;
        }];
      };
      peregrine-hdmi = {
        outputs = [
          {
            criteria = "Chimei Innolux Corporation 0x14F3 0x00000000";
            mode = "1920x1080@60Hz";
            position = "0,0";
            scale = 1.25;
          }
          {
            criteria = "HDMI-A-1";
            position = "1920,0";
          }
        ];
      };
      peregrine-docked = {
        outputs = [
          {
            criteria = "Chimei Innolux Corporation 0x14F3 0x00000000";
            mode = "1920x1080@60Hz";
            position = "0,1080";
            scale = 1.25;
          }
          {
            criteria = "ViewSonic Corporation VX3211-4K VJJ201920351";
            mode = "3840x2160@30Hz";
            position = "1920,0";
          }
          {
            criteria = "Unknown UHD HDMI 0x00000000";
            mode = "3840x2160@30Hz";
            position = "5760,0";
          }
        ];
      };
    };
  };

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

  # polkit authentication agent
  systemd.user.services.polkit-gnome = {
    Unit = {
      Description = "PolicyKit Authentication Agent";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "sway-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "always";
    };

    Install = { WantedBy = [ "sway-session.target" ]; };
  };

  # wofi
  xdg.configFile."wofi/style.css".source = ./wofi.css;
  home.tmpfs-as-home.persistentDirs = [
    ".cache/wofi"
  ];

  # screenshot
  xdg.configFile."swappy/config".text = ''
    [Default]
    save_dir=${config.xdg.userDirs.pictures}
    save_filename_format=Screenshot_%Y-%m-%d_%H:%M:%S.png
  '';

  # auto workspace renaming
  systemd.user.services.autoname-workspace = {
    Unit = {
      Description = "automatic workspace rename";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "sway-session.target" ];
    };

    Service = {
      ExecStart = "${autoname-workspaces} --duplicate";
      Restart = "always";
    };

    Install = { WantedBy = [ "sway-session.target" ]; };
  };

  home.packages = with pkgs; [
    # XXX workaround for home-manager #2806
    ngkz.sway-systemd

    ngkz.swaynotificationcenter-unstable
    swaylock-effects
    pkgs.wofi
    grim
    slurp
    swappy
    i3-swallow
  ];
}
