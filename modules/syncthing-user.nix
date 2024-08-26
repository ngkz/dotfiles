# See also: home/syncthing
{ ... }:

{
  networking.firewall = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 21027 22000 ];
  };

  age.secrets.syncthing = {
    file = ../secrets/syncthing.json.age;
    owner = "user";
    group = "users";
    mode = "0400";
  };
}
