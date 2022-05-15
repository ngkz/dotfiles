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
    enableDefaultFonts = false;
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji-blob-bin
      ibm-plex
      sarasa-gothic
    ];

    # Create a directory with links to all fonts in /run/current-system/sw/share/X11/fonts
    fontDir.enable = true;
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
