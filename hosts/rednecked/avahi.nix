{ lib, ... }:
let
  inherit (lib) mkForce;
in
{
  # See also: base.nix
  services.avahi = {
    allowInterfaces = [ "br_lan" "wg0" ];
    openFirewall = mkForce false;
    reflector = true;
  };

  networking.firewall.interfaces.br_lan.allowedUDPPorts = [ 5353 ];
  networking.firewall.interfaces.wg0.allowedUDPPorts = [ 5353 ];
}
