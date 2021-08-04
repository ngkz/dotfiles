{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption types mkIf;
in {
  imports = [
    ./printing.nix
    ./sway.nix
    ./greetd.nix
  ];

  options.f2l.workstation = mkOption {
    type = types.bool;
    default = false;
    description = "Whether the host is workstation";
  };

  config = mkIf config.f2l.workstation {
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

    boot.extraModulePackages = with config.boot.kernelPackages; [
      ddcci-driver # DDC/CI backlight control driver
    ];

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
  };
}
