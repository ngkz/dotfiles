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
        seat seat0 xcursor_theme ${config.home-manager.users.greeter.gtk.cursorTheme.name}
        exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -s /etc/greetd/gtkgreet.css; swaymsg exit"
        bindsym Mod4+shift+e exec ${pkgs.ngkz.hotkey-scripts}/bin/powermenu greeter
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

  users.users.greeter = {
    home = "/run/greeter";
    createHome = true;
  };

  nix.settings.allowed-users = [ "greeter" ];

  home-manager.users.greeter = {
    imports = [
      ../home/nixos.nix
      ../home/base.nix
      ../home/theming
    ];
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
