# See also: home/syncthing
{ ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22000 ]; # tailscale only

  age.secrets.syncthing = {
    file = ../secrets/syncthing.json.age;
    owner = "user";
    group = "users";
    mode = "0400";
  };
}
