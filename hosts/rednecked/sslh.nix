{ config, pkgs, lib, ... }:
let
  inherit (builtins) head toString;
  inherit (lib) mkForce;
in
{
  # sslh multi-protocol multiplexer
  services.sslh = {
    enable = true;
    transparent = true;
    verbose = true;
    appendConfig = ''
      protocols:
      (
        { name: "tls"; host: "localhost"; port: "${toString config.services.nginx.defaultSSLListenPort}"; probe: "builtin"; },
        { name: "ssh"; service: "ssh"; host: "localhost";
          port: "${toString (head config.services.openssh.ports)}";
          log_level: 1; probe: "builtin"; },
        { name: "anyprot"; host: "localhost"; port: "${toString config.services.nginx.defaultSSLListenPort}"; probe: "builtin"; }
      );
    '';
  };

  # prevent systemd-networkd removing sslh routing rules
  systemd.network.config.networkConfig = {
    ManageForeignRoutingPolicyRules = false;
    ManageForeignRoutes = false;
  };

  systemd.services.sslh =
    let
      ruleset = pkgs.writeText "10-sslh.nft" ''
        table inet sslh {
          chain raw-prerouting {
            type filter hook prerouting priority raw; policy accept;
            iifname != "lo" ip daddr 127.0.0.0/8 drop
            iifname != "lo" ip6 daddr ::1 drop
          }

          chain mangle-postrouting {
            type filter hook postrouting priority mangle; policy accept;
            oifname != "lo" ip saddr 127.0.0.0/8 drop
            oifname != "lo" ip6 saddr ::1 drop
          }

          chain nat-output {
            type nat hook output priority -100; policy accept;
            meta l4proto tcp skuid sslh tcp flags syn / fin,syn,rst,ack ct mark set 2
          }

          chain mangle-output {
            type route hook output priority mangle; policy accept;
            oifname != "lo" meta l4proto tcp ct mark 2 mark set 2
          }
        }
      ''; in
    {
      preStart = mkForce ''
        # update firewall rules
        cp ${ruleset} /etc/nftables.d/10-sslh.nft
        systemctl restart nftables

        # configure routing for those marked packets
        ip rule  add fwmark 0x2 lookup 100
        ip route add local 0.0.0.0/0 dev lo table 100
        ip -6 rule  add fwmark 0x2 lookup 100
        ip -6 route add local ::/0 dev lo table 100
      '';
      postStop = mkForce ''
        rm /etc/nftables.d/10-sslh.nft
        systemctl restart nftables

        ip rule  del fwmark 0x2 lookup 100
        ip route del local 0.0.0.0/0 dev lo table 100
        ip -6 rule  del fwmark 0x2 lookup 100
        ip -6 route del local ::/0 dev lo table 100
      '';
    };

  networking.firewall.allowedTCPPorts = [ 443 ];
}
