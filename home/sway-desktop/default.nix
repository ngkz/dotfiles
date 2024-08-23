{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkOptionDefault types concatStringsSep;

  swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
  swaymsg = "${pkgs.sway-unwrapped}/bin/swaymsg";
  pgrep = "${pkgs.procps}/bin/pgrep";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  cat = "${pkgs.coreutils}/bin/cat";
  swaync-client = "${pkgs.swaynotificationcenter}/bin/swaync-client";
  foot = "${pkgs.foot}/bin/foot";
  wofi = "${pkgs.wofi}/bin/wofi";
  autoname-workspaces = pkgs.writers.writePython3 "autoname-workspaces.py"
    { libraries = [ pkgs.python3Packages.i3ipc ]; } ./autoname-workspaces.py;
  sway = config.wayland.windowManager.sway.config;
  mod = sway.modifier;
  inherit (sway) left right up down;
  output0 = "u";
  output1 = "i";
  output2 = "o";
  output3 = "p";
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
    systemd.enable = false; # XXX workaround for home-manager #2806
    package = null; # use system sway package
    config = {
      modifier = "Mod4"; # Super
      terminal = foot;
      menu = "${wofi} --show drun --allow-images --columns 3 --lines 15 --cache-file ${config.xdg.cacheHome}/wofi/drun --insensitive";
      fonts = {
        names = [ "Sans Serif" ];
        style = "Medium";
        size = 9.5;
      };
      bars = [ ];
      colors.focused = {
        border = "#e02334";
        background = "#a0000e";
        text = "#ffffff";
        indicator = "#b5bd68";
        childBorder = "#e02334";
      };
      keybindings = mkOptionDefault {
        # additional workspaces
        "${mod}+1" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/workspace 1";
        "${mod}+2" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/workspace 2";
        "${mod}+3" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/workspace 3";
        "${mod}+4" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/workspace 4";
        "${mod}+5" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/workspace 5";
        "${mod}+6" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/workspace 6";
        "${mod}+7" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/workspace 7";
        "${mod}+8" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/workspace 8";
        "${mod}+9" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/workspace 9";
        "${mod}+0" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/workspace ${ws10}";
        "${mod}+minus" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/workspace ${ws11}";
        "${mod}+asciicircum" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/workspace ${ws12}";
        "${mod}+backslash" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/workspace ${ws13}";
        "${mod}+BackSpace" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/workspace ${ws14}";

        "${mod}+Shift+0" = "move container to workspace number ${ws10}";
        "${mod}+Shift+minus" = "move container to workspace number ${ws11}";
        "${mod}+Shift+asciicircum" = "move container to workspace number ${ws12}";
        "${mod}+Shift+backslash" = "move container to workspace number ${ws13}";
        "${mod}+Shift+BackSpace" = "move container to workspace number ${ws14}";

        # switch monitor
        "${mod}+${output0}" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/multihead focus 0";
        "${mod}+${output1}" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/multihead focus 1";
        "${mod}+${output2}" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/multihead focus 2";
        "${mod}+${output3}" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/multihead focus 3";

        # move container to another monitor
        "${mod}+Shift+${output0}" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/multihead move 0";
        "${mod}+Shift+${output1}" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/multihead move 1";
        "${mod}+Shift+${output2}" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/multihead move 2";
        "${mod}+Shift+${output3}" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/multihead move 3";

        # quick resize
        "${mod}+Control+${left}" = "resize shrink width 40px";
        "${mod}+Control+${down}" = "resize grow height 40px";
        "${mod}+Control+${up}" = "resize shrink height 40px";
        "${mod}+Control+${right}" = "resize grow width 40px";

        "${mod}+Tab" = "workspace back_and_forth";
        "${mod}+Shift+Tab" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/switch-window";
        "${mod}+Shift+a" = "focus child";
        "${mod}+q" = "split none";

        # new tab container
        "${mod}+t" = "exec 'swaymsg splith && swaymsg layout tabbed'";

        #"${mod}+d" = "";
        "${mod}+Shift+Return" = "exec ${sway.terminal} --app-id=foot-floating"; # spawn flaoting terminal
        "${mod}+Shift+e" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/powermenu";
        "${mod}+Escape" = "exec loginctl lock-session";

        # screenshot
        "Print" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/screenshot";

        # Move the currently focused window to the scratchpad
        "${mod}+Shift+Zenkaku_Hankaku" = "move scratchpad";
        # Show the next scratchpad window or hide the focused scratchpad window.
        # If there are multiple scratchpad windows, this command cycles through them.
        "${mod}+Zenkaku_Hankaku" = "scratchpad show";

        # media keys
        "XF86AudioRaiseVolume" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/volume up";
        "XF86AudioLowerVolume" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/volume down";
        "XF86AudioMute" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/volume mute";
        "XF86AudioMicMute" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/micmute";
        "XF86MonBrightnessUp" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/brightness up";
        "XF86MonBrightnessDown" = "exec ${pkgs.ngkz.hotkey-scripts}/bin/brightness down";

        # notification
        "${mod}+Shift+n" = "exec ${swaync-client} --toggle-panel --skip-wait";
        "${mod}+n" = "exec ${swaync-client} --close-latest --skip-wait";
      };
      input =
        let
          keyboard = {
            xkb_layout = "jp";
            xkb_options = "ctrl:nocaps";
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
            pointer_accel = "1.0";
          } // keyboard; # workaround for issue #5943
          # internal TrackPoint
          "2:10:TPPS/2_Elan_TrackPoint" = {
            pointer_accel = "1.0";
          };
        };
      output = {
        "*" = {
          bg = "${./wallpapers/DSC01320.JPG} fill";
        };
      };
      seat = {
        "*" = {
          xcursor_theme = config.gtk.cursorTheme.name;
        };
      };
      window = {
        titlebar = false;
        commands = [
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
              title = "KeePassXC - (ブラウザーの)?アクセス要求$";
            };
            command = "floating enable";
          }
          {
            # XXX FreeCAD splash
            criteria = {
              app_id = "org.freecadweb.FreeCAD$";
              title = "FreeCAD Link Branch$";
            };
            command = "floating enable";
          }
        ];
      };
    };
    extraConfig = ''
      # clamshell mode
      bindswitch --reload --locked lid:on output LVDS-1 disable, output eDP-1 disable
      bindswitch --reload --locked lid:off output LVDS-1 enable, output eDP-1 enable

      # XXX workaround for home-manager #2806
      exec ${pkgs.ngkz.sway-systemd-autostart}/libexec/sway-systemd/session.sh --with-cleanup --add-env=SDL_VIDEODRIVER --add-env=_JAVA_AWT_WM_NONREPARENTING --add-env=CLUTTER_BACKEND --add-env=MOZ_ENABLE_WAYLAND --add-env=NIXOS_OZONE_WL --add-env=GTK_IM_MODULE  --add-env=QT_IM_MODULE --add-env=XMODIFIERS --add-env=QT_QPA_PLATFORMTHEME

      # XXX workaround for kanshi #35
      exec_always systemctl restart --user kanshi
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
          "--image ${./wallpapers/DSC02942.JPG}"
          "--indicator-radius 175"
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
        # TODO read tlp state
        command = "[ \"$(${cat} /sys/class/power_supply/AC/online)\" = 0 ] && ${systemctl} suspend";
      }
    ];
  };

  services.kanshi = {
    enable = true;
    settings = [
      {
        profile = {
          name = "peregrine-undocked";
          outputs = [{
            criteria = "Chimei Innolux Corporation 0x14F3 Unknown";
            scale = 1.0;
          }];
        };
      }
      {
        profile = {
          name = "peregrine-hdmi";
          outputs = [
            {
              criteria = "Chimei Innolux Corporation 0x14F3 Unknown";
              mode = "1920x1080@60Hz";
              scale = 1.0;
              position = "0,0";
            }
            {
              criteria = "HDMI-A-1";
              position = "1920,0";
              scale = 1.0;
              status = "enable";
            }
          ];
        };
      }
      {
        profile = {
          name = "peregrine-docked";
          outputs = [
            {
              criteria = "Chimei Innolux Corporation 0x14F3 Unknown";
              mode = "1920x1080@60Hz";
              position = "0,720";
              scale = 1.5;
            }
            {
              criteria = "JRY UHD HDMI Unknown";
              mode = "3840x2160@30Hz";
              position = "1280,0";
              scale = 1.5;
              status = "enable";
            }
            {
              criteria = "ViewSonic Corporation VX3211-4K VJJ201920351";
              mode = "3840x2160@29.981Hz";
              position = "3840,0";
              scale = 1.5;
              status = "enable";
            }
          ];
        };
      }
    ];
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
  xdg.configFile."swaync/config.json" = {
    text = builtins.toJSON {
      widgets = [ "title" "dnd" "mpris" "notifications" ];
      notification-visibility = {
        bluetooth = {
          state = "transient";
          app-name = "blueman";
        };
      };
      scripts = {
        sound = {
          app-name = "^(?!volume|brightness|Tauon Music Box)(.*)$";
          summary = "^(?!Command completed in )(.*)";
          exec = "${pkgs.pulseaudio}/bin/paplay ${./airplane-announcement.ogg}";
        };
      };
    };
    onChange = ''
      if ${pgrep} -u $(id -u) -x swaync; then
        ${swaync-client} --reload-config
      fi
    '';
  };
  xdg.configFile."swaync/style.css" = {
    source = ./swaync.css;
    onChange = ''
      if ${pgrep} -u $(id -u) -x swaync; then
        ${swaync-client} --reload-css
      fi
    '';
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
  tmpfs-as-home.persistentDirs = [
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
      X-Restart-Triggers = [ "${autoname-workspaces}" ];
    };

    Service = {
      ExecStart = "${autoname-workspaces} --duplicate";
      Restart = "always";
    };

    Install = { WantedBy = [ "sway-session.target" ]; };
  };

  home.packages = with pkgs; [
    # XXX workaround for home-manager #2806
    ngkz.sway-systemd-autostart

    swaynotificationcenter
    swaylock-effects
    pkgs.wofi
    grim
    slurp
    swappy
    i3-swallow
    wdisplays
    wev
    gnome.gnome-power-manager
    networkmanagerapplet
  ];
}
