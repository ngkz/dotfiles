{ ... }: {
  fileSystems = import ./fileSystems.nix {
    bootDev = "/dev/disk/by-uuid/CACA-B820";
    rootDev = "/dev/disk/by-uuid/a15d98dd-3561-486f-9a3b-adfee684a63d";
    hddDev = "/dev/disk/by-uuid/1a3d5415-471d-4f72-ad9c-268c9071628a"; # bcache
  };
  swapDevices = [
    {
      device = "/var/swap/swapfile";
      discardPolicy = "once";
    }
  ];

  tmpfs-as-root.enable = true;

  modules.btrfs-maintenance = {
    fileSystems = [
      # scrubbling one of subvolumes scrubs the whole filesystem
      "/var/persist"
      "/var/spinningrust"
    ];

    defragMounts = [
      # "/nix"
      # "/var/persist"
      "/var/spinningrust"
    ];
  };
}
