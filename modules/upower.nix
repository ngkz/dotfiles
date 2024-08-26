# power management / statistics daemon
{ config, lib, ... }:
{
  imports = [
    ./tmpfs-as-root.nix
  ];

  services.upower.enable = true;
  tmpfs-as-root.persistentDirs = [ "/var/lib/upower" ];
  systemd.services.upower.serviceConfig = lib.mkIf config.tmpfs-as-root.enable {
    StateDirectory = "";
    ReadWritePaths = [
      "/var/lib/upower"
      "${config.tmpfs-as-root.storage}/var/lib/upower"
    ];
  };
}
