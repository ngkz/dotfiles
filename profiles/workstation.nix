# configuration applied to all workstations

{ config, pkgs, ... }:
{
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
