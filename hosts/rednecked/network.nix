{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    netdevs = {
      "20-lanbr0" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "lanbr0";
        };
      };
    };
    networks = {
      "30-enp1s0f0" = {
        matchConfig.Name = "enp1s0f0";
        networkConfig.Bridge = "lanbr0";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-enp1s0f1" = {
        matchConfig.Name = "enp1s0f1";
        networkConfig.Bridge = "lanbr0";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-enp1s0f2" = {
        matchConfig.Name = "enp1s0f2";
        networkConfig.Bridge = "lanbr0";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-enp1s0f3" = {
        matchConfig.Name = "enp1s0f3";
        networkConfig.Bridge = "lanbr0";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "40-lanbr0" = {
        matchConfig.Name = "lanbr0";
        address = [ "192.168.18.4/24" ];
        gateway = [ "192.168.18.1" ];
        dns = [ "192.168.18.1" ];
        networkConfig = {
          # configure IPv6 with RA
          IPv6AcceptRA = true;
        };
        linkConfig = {
          RequiredForOnline = "routable";
        };
      };
    };
  };
}
