# Tailscale WireGuard mesh VPN
{ ... }:

{
  imports = [
    ../tmpfs-as-root.nix
  ];

  services.tailscale = {
    enable = true;
    # openFirewall = true;
  };

  tmpfs-as-root.persistentDirs = [
    "/var/lib/tailscale"
  ];
}
