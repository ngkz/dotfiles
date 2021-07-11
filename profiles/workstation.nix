# configuration applied to all workstations

{ config, pkgs, ... }:
{
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # mDNS
  services.avahi = {
    enable = true;
    nssmdns = true; # *.local resolution
    publish.enable = true;
    publish.addresses = true; # make this host accessible with <hostname>.local
  };

  # Scanners
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan ];
  };
  users.users.user.extraGroups = [ "scanner" "lp" ];

  # greetd display manager
  environment.etc = let
    background = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
  in {
      "greetd/sway-config".text = ''
        output * bg ${background} fill
        seat seat0 xcursor_theme Adwaita
        exec "GTK_THEME=Adwaita:dark ${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -s /etc/greetd/gtkgreet.css; swaymsg exit"
        bindsym Mod4+shift+e exec swaynag \
            -t warning \
            -m 'What do you want to do?' \
            -b 'Suspend' 'systemctl suspend' \
            -b 'Poweroff' 'systemctl poweroff' \
            -b 'Reboot' 'systemctl reboot'
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

  # Sway wayland compositor
  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      dmenu
      qt5.qtwayland
    ];
    extraSessionCommands = ''
      # redirect log to journal
      exec > >(${pkgs.util-linux}/bin/logger -t sway) 2>&1

      # SDL:
      export SDL_VIDEODRIVER=wayland
      # QT (needs qt5.qtwayland in systemPackages):
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
      # Clutter:
      export CLUTTER_BACKEND=wayland
      # Firefox:
      export MOZ_ENABLE_WAYLAND=1
      export MOZ_WEBRENDER=1
      ${if config.virtualisation.virtualbox.guest.enable then ''
        # Workaround for sway #3814
        export WLR_NO_HARDWARE_CURSORS=1
      '' else ""}
    '';
    wrapperFeatures.gtk = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    gtkUsePortal = true;
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [
    ddcci-driver # DDC/CI backlight control driver
  ];

  environment.systemPackages = with pkgs; with linuxPackages; [
    binutils
    ethtool
    gdb
    inotify-tools
    powertop
    s-tui
    tldr
    turbostat
    wl-clipboard

    firefox #nixpkgs doesn't have librewolf yet
    #gnome.dconf-editor
    freecad
    gimp
    gnome.adwaita-icon-theme
    gscan2pdf #scanning tool
    keepassxc
    lollypop
    termite
    ungoogled-chromium
    xdg-utils
  ];

  # install fonts
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji-blob-bin
    sarasa-gothic
  ];

  # XDG user dirs
  home-manager.users.user.xdg.userDirs.enable = true;

  # Persistence
  systemd.tmpfiles.rules = [
    "d /nix/persist/home/user 700 user users -"

    # XDG user dirs
    "d /nix/persist/home/user/Desktop - user users -"
    "L /home/user/Desktop - - - - /nix/persist/home/user/Desktop"
    "d /nix/persist/home/user/Documents - user users -"
    "L /home/user/Documents - - - - /nix/persist/home/user/Documents"
    "d /nix/persist/home/user/Downloads - user users -"
    "L /home/user/Downloads - - - - /nix/persist/home/user/Downloads"
    "d /nix/persist/home/user/Music - user users -"
    "L /home/user/Music - - - - /nix/persist/home/user/Music"
    "d /nix/persist/home/user/Pictures - user users -"
    "L /home/user/Pictures - - - - /nix/persist/home/user/Pictures"
    # I don't use Templates and Public
    "d /nix/persist/home/user/Videos - user users -"
    "L /home/user/Videos - - - - /nix/persist/home/user/Videos"
  ];
}
