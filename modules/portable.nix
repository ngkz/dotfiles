# Configuration for portable (phone or laptop) hosts
{ config, lib, ... }:
{
  # better timesync for unstable internet connections
  services.timesyncd.enable = false;
  services.chrony = {
    enable = true;
    directory = "/nix/persist/var/lib/chrony";
  };
}
