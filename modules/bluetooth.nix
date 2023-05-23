{ config, ... }: {
  hardware.bluetooth.enable = true;
  systemd.services.bluetooth.serviceConfig = {
    StateDirectory = "";
    ReadWritePaths = [
      "/var/lib/bluetooth"
      "${config.modules.tmpfs-as-root.storage}/var/lib/bluetooth"
    ];
  };
  modules.tmpfs-as-root.persistentDirs = [
    # bluetooth
    "/var/lib/bluetooth"
  ];
}
