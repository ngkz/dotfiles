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

  hosts.rednecked.network.internalInterfaces.allowedUDPPorts = [ 5353 ];
}
