# Configuration for portable (phone or laptop) hosts
{ config, lib, ... }:
{
  # better timesync for unstable internet connections
  services.timesyncd.enable = false;
  services.chrony = {
    enable = true;
    directory = "${config.modules.tmpfs-as-root.storage}/var/lib/chrony";
  };
}
