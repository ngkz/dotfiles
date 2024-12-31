{ config, options, lib, ... }:
let
  inherit (lib) mkOption types optionalString concatStringsSep;
in
{
  options.hosts.rednecked.network = {
    lan = mkOption {
      type = types.str;
    };

    internalInterfaces = {
      allowedTCPPorts = options.networking.firewall.allowedTCPPorts;
      allowedUDPPorts = options.networking.firewall.allowedUDPPorts;
    };
  };

  config =
    let
      cfg = config.hosts.rednecked.network;
    in
    {
      hosts.rednecked.network.lan = "192.168.18.0/24";
      networking.useDHCP = false;
      systemd.network = {
        enable = true;
        links = {
          "10-wan_hgw" = {
            matchConfig.MACAddress = "2c:53:4a:07:f9:03";
            linkConfig.Name = "wan_hgw";
          };
        };
        networks = {
          "30-wan_hgw" = {
            matchConfig.Name = "wan_hgw";
            # configure IPv6 with RA and DHCPv6, no DHCPv6-PD
            # configure IPv4 with DHCP
            DHCP = "yes";
            networkConfig = {
              IPv6AcceptRA = true;
            };
            ipv6AcceptRAConfig = {
              Token = "::f21";
            };
            linkConfig.RequiredForOnline = "routable";
          };
        };
      };

      networking.nftables.enable = true;
      networking.firewall = {
        filterForward = true;
        extraInputRules =
          let
            ifaceNetwork = "iifname \"wan_hgw\" ip saddr ${cfg.lan}";
            nftSet = ports: concatStringsSep ", " (map toString ports);
            tcpSet = nftSet cfg.internalInterfaces.allowedTCPPorts;
            udpSet = nftSet cfg.internalInterfaces.allowedUDPPorts;
          in
          ''
            ${optionalString (tcpSet != "") "${ifaceNetwork} tcp dport { ${tcpSet} } accept"}
            ${optionalString (udpSet != "") "${ifaceNetwork} udp dport { ${udpSet} } accept"}
          '';
        # ports for ssh reverse forwarding
        # allowedTCPPorts = [ 1024 1025 1026 1027 1028 ];
      };

      services.networkd-dispatcher.enable = true;
    };
}
