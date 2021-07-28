# configuration applied to all workstations

{ config, pkgs, lib, ... }: {
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

  # Printers
  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint ];
  };
  hardware.printers = {
    ensureDefaultPrinter = "MX923";
    ensurePrinters = [
      {
        description = "Canon PIXUS MX923";
        deviceUri = "dnssd://Canon%20MX920%20series._ipp._tcp.local/?uuid=00000000-0000-1000-8000-84BA3B85F5A1";
        model = "gutenprint.${lib.versions.majorMinor (lib.getVersion pkgs.gutenprint)}://bjc-MX920-series/expert";
        name = "MX923";
      }
    ];
  };
  programs.system-config-printer.enable = true;

  # Scanners
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan ];
  };

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
    qt5.qtwayland

    binutils
    ethtool
    gdb
    inotify-tools
    powertop
    turbostat
    wl-clipboard

    firefox #nixpkgs doesn't have librewolf yet
    foot
    gnome.dconf-editor
    freecad
    gimp
    gnome.adwaita-icon-theme
    gscan2pdf #scanning tool
    imv
    keepassxc
    lollypop
    ungoogled-chromium
    wireshark
    wdisplays
    xdg-utils
    xfce.thunar
    xfce.thunar-archive-plugin
    zathura #pdf viewer
  ];

  # install fonts
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji-blob-bin
    sarasa-gothic
  ];

  # Create a directory with links to all fonts in /run/current-system/sw/share/X11/fonts
  fonts.fontDir.enable = true;

  # XDG user dirs
  home-manager.users.user.xdg.userDirs = {
    enable = true;
    desktop = "$HOME";
    documents = "$HOME/docs";
    download = "$HOME/dl";
    music = "$HOME/music";
    pictures = "$HOME/pics";
    publicShare = "$HOME";
    templates = "$HOME";
    videos = "$HOME/videos";
  };

  # Wireshark
  programs.wireshark.enable = true;

  # Persistence
  home-manager.users.user.home.persist.directories = [
    # Home directory
    "docs"
    "dl"
    "music"
    "pics"
    "videos"
    "projects"
    "work"
    "misc"
  ];

  # Git
  home-manager.users.user.programs.git = {
    enable = true;
    delta.enable = true;
  };

  # Extra groups
  users.users.user.extraGroups = [
    # Scanner
    "scanner" "lp"

    # Wireshark
    "wireshark"
  ];
}
