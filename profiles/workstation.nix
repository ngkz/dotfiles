# configuration applied to all workstations

{ config, pkgs, ... }:
{
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable PipeWire sound daemon.
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

  environment.systemPackages = with pkgs; [
    git
    binutils
    python
  ];
}
