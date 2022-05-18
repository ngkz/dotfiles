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
      sarasa-gothic
      my.plemoljp-nf
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
        emoji = [ "Bjobmoji" ];
        monospace = [ "PlemolJP Console NF" ];
      };
      cache32Bit = true;
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
