# automatically take /home hourly btrfs snapshot
{ config, ... }:

{
  imports = [
    ./tmpfs-as-root.nix
  ];

  security.sudo.execWheelOnly = false; # btrbk uses sudo
  services.btrbk = {
    instances.btrbk = {
      settings = {
        snapshot_preserve_min = "latest";
        snapshot_preserve = "24h 2d";
        subvolume = "${config.tmpfs-as-root.storage}/home";
        snapshot_dir = "/var/snapshots";
      };
      onCalendar = "hourly";
    };
  };
}
