{ lib, ... }:
let
  inherit (lib) mkForce;
in
{
  # See also: modules/mdns.nix
  services.avahi = {
    allowInterfaces = [ "br_lan" ];
    openFirewall = mkForce false;
  };

  networking.firewall.interfaces.br_lan.allowedUDPPorts = [ 5353 ];
}
