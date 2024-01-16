{ config, ... }: {
  hardware.bluetooth.enable = true;
  systemd.services.bluetooth.serviceConfig = {
    StateDirectory = "";
    ReadWritePaths = [
      "/var/lib/bluetooth"
      "${config.tmpfs-as-root.storage}/var/lib/bluetooth"
    ];
  };
  tmpfs-as-root.persistentDirs = [
    # bluetooth
    "/var/lib/bluetooth"
  ];
}
