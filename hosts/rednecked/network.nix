{ config, options, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.hosts.rednecked.network = {
    lan_prefix = mkOption {
      type = types.str;
      default = "192.168.18";
    };

    internalInterfaces = {
      allowedTCPPorts = options.networking.firewall.allowedTCPPorts;
      allowedUDPPorts = options.networking.firewall.allowedUDPPorts;
    };
  };

  config = {
    networking.useDHCP = false;
    systemd.network = {
      enable = true;
      links = {
        "10-wan_hgw" = {
          matchConfig.MACAddress = "2c:53:4a:07:f9:03";
          linkConfig.Name = "wan_hgw";
        };
        "10-lan0" = {
          matchConfig.MACAddress = "2c:53:4a:07:f9:02";
          linkConfig.Name = "lan0";
        };
        "10-lan1" = {
          matchConfig.MACAddress = "2c:53:4a:07:f9:01";
          linkConfig.Name = "lan1";
        };
        "10-lan2" = {
          matchConfig.MACAddress = "2c:53:4a:07:f9:00";
          linkConfig.Name = "lan2";
        };
        "10-lan3" = {
          matchConfig.MACAddress = "f4:b5:20:1b:02:68";
          linkConfig.Name = "lan3";
        };
        "10-wlan_24g" = {
          matchConfig.MACAddress = "30:10:b3:03:41:51";
          linkConfig.Name = "wlan_24g";
        };
      };
      netdevs = {
        "20-br_lan" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "br_lan";
          };
        };
        # TODO MAP-E
        #"20-wan_mape" = {
        #  netdevConfig = {
        #    Kind = "ip6tnl";
        #    Name = "wan_mape";
        #  };
        #  tunnelConfig = {
        #    Mode = "ipip6";
        #    #2400:4051:c520:1e00:a52a:dc06:da8:832c
        #    Local = "2400:4051:c520:1e00:76:8d4:8000:1e00"; #TODO auto update CE
        #    Remote = "2001:380:a120::9"; #TODO auto update BR
        #    DiscoverPathMTU = true;
        #    EncapsulationLimit = "none";
        #  };
        #};
      };
      networks = {
        "30-wan_hgw" = {
          matchConfig.Name = "wan_hgw";
          # configure IPv6 with DHCPv6-PD
          # configure IPv4 with DHCP to access HGW setup
          DHCP = "yes";
          networkConfig = {
            DHCPPrefixDelegation = true;
            IPv6AcceptRA = true;
            IPForward = true;

            # TODO MAP-E
            # Tunnel = "wan_mape";
            # Address = "2400:4051:c520:1e00:76:8d4:8000:1e00/64"; #TODO auto update CE
            # # this is just in case you are given the same IP as CE by the ISP (not sure
            # # if it actually happens; it didn't for me)
            # DuplicateAddressDetection = false;
          };
          dhcpV4Config = {
            UseDNS = false;
            UseRoutes = false; # HGW is not connected to the IPv4 internet
            UseHostname = false;
          };
          dhcpV6Config = {
            WithoutRA = "solicit";
            UseNTP = true;
          };
          ipv6AcceptRAConfig = {
            Token = "::f21";
          };
          dhcpPrefixDelegationConfig = {
            UplinkInterface = ":self";
            Announce = false;
            Assign = false;
          };
          linkConfig.RequiredForOnline = "routable";
        };
        # TODO MAP-E
        # "30-wan_mape" = {
        #   matchConfig.Name = "wan_mape";
        #   networkConfig = {
        #     BindCarrier = "wan_hgw";
        #     IPv6AcceptRA = false;
        #     LinkLocalAddressing = "no";
        #   };
        #   routes = [{
        #     routeConfig = {
        # Gateway = "0.0.0.0";
        # Metric = 10; # Prefer MAP-E over PPPoE
        # };
        #   }];
        # };
        "30-wan_pppoe" = {
          matchConfig.Name = "wan_pppoe";
          networkConfig = {
            KeepConfiguration = "static";
            IPv6AcceptRA = false;
            LinkLocalAddressing = "no";
          };
          routes = [{
            routeConfig = {
              Gateway = "0.0.0.0";
              Metric = 20; # Prefer MAP-E over PPPoE
            };
          }];
          linkConfig.RequiredForOnline = "routable";
        };
        "30-lan0" = {
          matchConfig.Name = "lan0";
          networkConfig.Bridge = "br_lan";
          linkConfig.RequiredForOnline = false;
        };
        "30-lan1" = {
          matchConfig.Name = "lan1";
          networkConfig.Bridge = "br_lan";
          linkConfig.RequiredForOnline = false;
        };
        "30-lan2" = {
          matchConfig.Name = "lan2";
          networkConfig.Bridge = "br_lan";
          linkConfig.RequiredForOnline = false;
        };
        "30-lan3" = {
          matchConfig.Name = "lan3";
          networkConfig.Bridge = "br_lan";
          linkConfig.RequiredForOnline = false;
        };
        "30-wlan_24g" = {
          matchConfig.Name = "wlan_24g";
          networkConfig.Bridge = "br_lan";
          linkConfig.RequiredForOnline = false;
        };
        "40-br_lan" = {
          matchConfig.Name = "br_lan";
          address = [ "${config.hosts.rednecked.network.lan_prefix}.1/24" ];
          networkConfig = {
            DHCPPrefixDelegation = true;
            IPv6AcceptRA = false;
            IPForward = true;
          };
          dhcpPrefixDelegationConfig = {
            UplinkInterface = "wan_hgw";
            SubnetId = 1;
            Token = "::1";
          };
          linkConfig.RequiredForOnline = false;
        };
      };
    };

    networking.nat = {
      enable = true;
      internalInterfaces = [ "br_lan" "wg0" ];
      externalInterface = "wan_pppoe"; #TODO MAP-E
    };

    networking.nftables.enable = true;
    networking.firewall = {
      filterForward = true;
      extraForwardRules = ''
        iifname { "br_lan", "wg0" } oifname { "wan_hgw" } accept comment "internal network to HGW"
        iifname { "br_lan", "wg0" } oifname { "br_lan", "wg0" } accept comment "between LAN and VPN clients"
      '';
      interfaces =
        let
          fwcfg = config.hosts.rednecked.network.internalInterfaces;
        in
        {
          br_lan = fwcfg;
          wg0 = fwcfg;
        };
    };

    services.networkd-dispatcher.enable = true;
  };
}
