{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/tailscale/common.nix
  ];

  # enable subnet router and exit node (route all traffic)
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraSetFlags = [
    "--advertise-routes=${config.hosts.rednecked.network.lan_prefix}.0/24,192.168.33.0/24" # allow routing traffic from other nodes to lan
    "--accept-routes" # route traffic to other lan
    "--advertise-exit-node" # allow allow routing traffic through this node
  ];


  # https://tailscale.com/kb/1320/performance-best-practices
  services.tailscale.openFirewall = true;
  services.networkd-dispatcher.rules."50-tailscale" = {
    onState = [ "routable" ];
    script = ''
      #!${pkgs.runtimeShell}
      ${lib.getExe pkgs.ethtool} -K wan_pppoe rx-udp-gro-forwarding on rx-gro-list off
      ${lib.getExe pkgs.ethtool} -K wan_hgw rx-udp-gro-forwarding on rx-gro-list off
    '';
  };

}
