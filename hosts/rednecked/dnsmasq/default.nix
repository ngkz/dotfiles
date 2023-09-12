{ config, pkgs, ... }:
let
  inherit (config.hosts.rednecked.network) lan_prefix;
in
{
  services.resolved.enable = false;
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    settings = {
      interface = [ "br_lan" "wg0" ];
      bind-interfaces = true;
      domain-needed = true;
      bogus-priv = true;
      domain = "home.arpa";
      dhcp-authoritative = true;
      dhcp-option = [
        "option:netmask,255.255.255.0"
        "option:router,0.0.0.0"
        "option:dns-server,0.0.0.0"
        "option:ntp-server,0.0.0.0"

        "option6:dns-server,[::]"
        "option6:ntp-server,[::]"
      ];
      enable-ra = true;
      dhcp-range = [
        "${lan_prefix}.32,${lan_prefix}.254,12h"
        "::,ra-stateless,ra-names,constructor:br_lan"
      ];
      dhcp-host = [
        "id:pererine,${lan_prefix}.4"
      ];
      no-hosts = true;
      log-dhcp = true;
      log-queries = true;
      no-resolv = true;
      conf-dir = "/etc/dnsmasq.d";
    };
  };

  networking.firewall.interfaces =
    let
      ports = {
        allowedTCPPorts = [
          53 #DNS
        ];
        allowedUDPPorts = [
          53 # DNS
          67 # DHCPv4 server
          547 # DHCPv6 server
        ];
      };
    in
    {
      br_lan = ports;
      wg0 = ports;
    };

  systemd.tmpfiles.rules = [
    "d /etc/dnsmasq.d 0755 root root -"
  ];

  services.networkd-dispatcher.rules."10-update-dnsmasq" = {
    onState = [ "configured" ];
    script = builtins.readFile (pkgs.substituteAll {
      src = ./update-dnsmasq.py;
      inherit (pkgs) python3 systemd;
    });
  };

  modules.tmpfs-as-root.persistentDirs = [ "/var/lib/dnsmasq" ];
}
