# configuration applied to portable(phone/laptop) hosts
{ config, pkgs, ... }:
{
  # better timesync for unstable internet connections
  services.timesyncd.enable = false;
  services.chrony = {
    enable = true;
    directory = "/nix/persist/var/lib/chrony";
  };
}
