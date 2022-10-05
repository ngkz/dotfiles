{ config, pkgs, lib, ... }: {
  imports = [
    ./printing.nix
    ./network-manager.nix
    ./gpg.nix
  ];

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

  environment.systemPackages = with pkgs; with linuxPackages; [
    turbostat
    libva-utils
  ];

  # install fonts
  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji-blob-bin
      corefonts
      dejavu_fonts
      freefont_ttf
      gyre-fonts # TrueType substitutes for standard PostScript fonts
      liberation_ttf
      unifont
      ibm-plex
      ngkz.sarasa-term-j-nerd-font
    ];

    # Create a directory with links to all fonts in /run/current-system/sw/share/X11/fonts
    fontDir.enable = true;

    fontconfig = {
      defaultFonts = {
        sansSerif = [ "IBM Plex Sans JP" ];
        serif = [
          "IBM Plex Serif"
          "Noto Serif CJK JP"
        ];
        emoji = [ "Blobmoji" ];
        monospace = [ "Sarasa Term J Nerd Font" ];
      };
      cache32Bit = true;
      # XXX Workaround for nixpkgs#46323
      localConf = builtins.readFile "${pkgs.ngkz.blobmoji-fontconfig}/etc/fonts/conf.d/75-blobmoji.conf";
    };
  };

  programs.wireshark.enable = true;
  programs.light.enable = true;

  # Extra groups
  users.users.user.extraGroups = [
    # Wireshark
    "wireshark"

    # light
    "video"
  ];

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "suspend";
    extraConfig = "HandlePowerKey=suspend";
  };

  services.upower.enable = true;
  modules.tmpfs-as-root.persistentDirs = [ "/var/lib/upower" ];
  systemd.services.upower.serviceConfig = {
    StateDirectory = "";
    ReadWritePaths = [
      "/var/lib/upower"
      "${config.modules.tmpfs-as-root.storage}/var/lib/upower"
    ];
  };

  services.blueman.enable = true;

  # increase maximum fan speed
  services.thinkfan = {
    enable = true;
    levels = [
      [ "level auto" 0 70 ]
      [ "level full-speed" 65 32767 ]
    ];
  };
  systemd.services.thinkfan.unitConfig.ConditionPathExists = [ "/proc/acpi/ibm/fan" ];

  hardware.trackpoint = {
    enable = true;
    speed = 255;
    device = "TPPS/2 Elan Trackpoint";
  };

  # install debug symbols
  environment.enableDebugInfo = true;

  # Syncthing
  networking.firewall = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 21027 22000 ];
  };

  age.secrets.syncthing = {
    file = ../../secrets/syncthing.json.age;
    owner = "user";
    group = "users";
    mode = "0400";
  };

  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;

  hardware.opengl.extraPackages = with pkgs; [
    intel-compute-runtime
    intel-ocl
  ];
}
