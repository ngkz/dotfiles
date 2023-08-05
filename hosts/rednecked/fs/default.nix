{ ... }: {
  # TODO: benchmark compression
  fileSystems = import ./fileSystems.nix {
    bootDev = "/dev/disk/by-uuid/TODO";
    rootDev = "/dev/disk/by-uuid/TODO";
    hddDev = "/dev/disk/by-uuid/TODO"; # bcache
  };
  swapDevices = [
    {
      device = "/var/swap/swapfile";
      discardPolicy = "once";
    }
  ];

  modules.tmpfs-as-root.enable = true;

  modules.btrfs-maintenance = {
    fileSystems = [
      # scrubbling one of subvolumes scrubs the whole filesystem
      "/var/persist"
      "/var/spinningrust"
    ];

    defragMounts = [
      "/nix"
      "/var/persist"
      "/var/spinningrust"
    ];
  };
}
