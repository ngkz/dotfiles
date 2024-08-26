# Tailscale client
{ ... }:

{
  imports = [
    ./common.nix
  ];

  services.tailscale = {
    useRoutingFeatures = "client";
    extraSetFlags = [
      "--accept-routes" # route traffic to other lan
    ];
  };
}
