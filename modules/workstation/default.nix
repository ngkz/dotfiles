{ config, pkgs, lib, ... }: {
  imports = [
    ./printing.nix
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
      noto-fonts-cjk
      noto-fonts-emoji-blob-bin
      corefonts
      dejavu_fonts
      freefont_ttf
      gyre-fonts # TrueType substitutes for standard PostScript fonts
      liberation_ttf
      unifont
      ibm-plex
      my.sarasa-term-j-nerd-font
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
        monospace = [ "Sarasa Term J Nerd Fonts" ];
      };
      cache32Bit = true;
      # XXX Workaround for nixpkgs#46323
      localConf = builtins.readFile "${pkgs.my.blobmoji-fontconfig}/etc/fonts/conf.d/75-blobmoji.conf";
    };
  };

  # Wireshark
  programs.wireshark.enable = true;

  # Extra groups
  users.users.user.extraGroups = [
    # Wireshark
    "wireshark"
  ];

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "suspend";
    extraConfig = "HandlePowerKey=suspend";
  };
}
