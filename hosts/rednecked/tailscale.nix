{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/tailscale/common.nix
  ];

  # enable subnet router and exit node (route all traffic)
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = [
    "--advertise-routes=${config.hosts.rednecked.network.lan}" # allow routing traffic from other nodes to lan
    "--accept-routes" # route traffic to other lan
    "--advertise-exit-node" # allow allow routing traffic through this node
  ];


  # https://tailscale.com/kb/1320/performance-best-practices
  services.tailscale.openFirewall = true;
  services.networkd-dispatcher.rules."50-tailscale" = {
    onState = [ "routable" ];
    script = ''
      #!${pkgs.runtimeShell}
      NETDEV=$(${pkgs.iproute2}/bin/ip route show 0/0 | ${pkgs.coreutils}/bin/cut -f5 -d' ')
      ${lib.getExe pkgs.ethtool} -K "$NETDEV" rx-udp-gro-forwarding on rx-gro-list off
    '';
  };

}
