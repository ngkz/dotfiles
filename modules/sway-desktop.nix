# sway + greetd
{ config, pkgs, ... }:
{
  # Sway wayland tiling compositor
  programs.sway = {
    enable = true;
    extraPackages = [ ];
    extraSessionCommands = ''
      # SDL:
      export SDL_VIDEODRIVER=wayland
      # Qt (needs qt5.qtwayland in systemPackages):
      export QT_QPA_PLATFORM="wayland;xcb"
      #export QT_WAYLAND_FORCE_DPI=physical
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
      # Clutter:
      export CLUTTER_BACKEND=wayland
      # Firefox:
      export MOZ_ENABLE_WAYLAND=1
      export MOZ_WEBRENDER=1
      # Chromium / Electron (experimental):
      export NIXOS_OZONE_WL=1

      # Log sway stdout/stderr
      exec &> >(${pkgs.systemd}/bin/systemd-cat -t sway)
    '';
    wrapperFeatures.gtk = true;
  };

  hardware.opengl.driSupport32Bit = true; #32bit OpenGL

  # greetd display manager
  environment.etc =
    let
      background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
    in
    {
      "greetd/sway-config".text = ''
        output * bg ${background} fill
        seat seat0 xcursor_theme Adwaita
        exec "GTK_THEME=Adwaita:dark ${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -s /etc/greetd/gtkgreet.css; swaymsg exit"
        bindsym Mod4+shift+e exec "GTK_THEME=Adwaita:dark ${pkgs.wlogout}/bin/wlogout -l /etc/greetd/wlogout-layout -b 2 -p layer-shell"
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

      "greetd/wlogout-layout".text = ''
        {
            "label" : "suspend",
            "action" : "systemctl suspend",
            "text" : "Suspend",
            "keybind" : "u"
        }
        {
            "label" : "hibernate",
            "action" : "systemctl hibernate",
            "text" : "Hibernate",
            "keybind" : "h"
        }
        {
            "label" : "shutdown",
            "action" : "systemctl poweroff",
            "text" : "Shutdown",
            "keybind" : "s"
        }
        {
            "label" : "reboot",
            "action" : "systemctl reboot",
            "text" : "Reboot",
            "keybind" : "r"
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
    gtkUsePortal = true;
  };
}
