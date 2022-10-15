# sway + greetd
{ config, pkgs, lib, ... }:
{
  # Sway wayland tiling compositor
  programs.sway = {
    enable = true;
    extraPackages = [ ];
    extraSessionCommands = ''
      # SDL:
      export SDL_VIDEODRIVER=wayland
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
      # Clutter:
      export CLUTTER_BACKEND=wayland
      # Firefox:
      export MOZ_ENABLE_WAYLAND=1
      # Chromium / Electron (experimental):
      export NIXOS_OZONE_WL=1
      # GTK
      # use wayland immodule
      unset GTK_IM_MODULE

      # Log sway stdout/stderr
      exec &> >(${pkgs.systemd}/bin/systemd-cat -t sway)
    '';
    wrapperFeatures.gtk = true;
  };

  hardware.opengl.driSupport32Bit = true; #32bit OpenGL

  modules.ccache.packagePaths = [ [ "xwayland" ] ];

  # greetd display manager
  environment.etc =
    let
      background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
      power-menu = pkgs.writeShellScript "power-menu" ''
        set -euo pipefail

        PATH=${lib.makeBinPath (with pkgs; [ coreutils wofi gawk systemd sway ])}

        op=$(cat <<EOS | wofi -p "Power" -G --style ${../home/sway-desktop/wofi.css} -i --dmenu --width 250 --height 210 --cache-file /dev/null | awk '{ print tolower($2) }'
         Poweroff
        ‎ﰇ Reboot
         Suspend
         Hibernate
        EOS
        )
        case "$op" in
        poweroff)
          systemctl poweroff -i
          ;;
        reboot|suspend|hibernate)
          systemctl "$op"
          ;;
        esac
      '';
    in
    {
      "greetd/sway-config".text = ''
        output * bg ${background} fill
        seat seat0 xcursor_theme Adwaita
        exec "GTK_THEME=Adwaita:dark ${pkgs.greetd.gtkgreet}/bin/gtkgreet -s /etc/greetd/gtkgreet.css; swaymsg exit"
        bindsym Mod4+shift+e exec ${power-menu}
        default_border none
        include /etc/sway/config.d/*
      '';

      # gtkgreet list of login environments
      "greetd/environments".text = ''
        sway
        zsh
      '';

      "greetd/gtkgreet.css".text = ''
        window {
          background-image: url("file://${background}");
          background-size: cover;
          background-position: center;
        }
      '';
    };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "sway --config /etc/greetd/sway-config";
        user = "greeter";
      };

      initial_session = {
        command = "sway";
        user = "user";
      };
    };
    restart = false;
  };

  environment.systemPackages = with pkgs; [
    gnome.adwaita-icon-theme # gtkgreet
    qt5.qtwayland
  ];

  # XDG Portal
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    gtkUsePortal = false; #XXX nixpkgs#179204. remove this after NixOS 21.11 upgrade
  };

  # systemd.user.services.xdg-desktop-portal.serviceConfig.ExecStart = lib.mkForce [
  #   # Empty ExecStart value to override the field
  #   ""
  #   "${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal -v"
  # ];

  # systemd.user.services.xdg-desktop-portal-wlr.serviceConfig.ExecStart = lib.mkForce [
  #   # Empty ExecStart value to override the field
  #   ""
  #   "${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr -l DEBUG"
  # ];
}
