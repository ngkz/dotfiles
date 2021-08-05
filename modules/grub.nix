{ config, ... }:
{
  modules.tmpfs-as-root.persistentDirs = [
    "/boot"
  ];

  fileSystems."/nix/persist/boot/efi" = {
    label = "ESP";
    fsType = "vfat";
  };

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/nix/persist/boot/efi"; # ESP mount point
    };

    grub = {
      enable = true;
      efiSupport = true;

      # install-grub.pl goes bananas if /boot or /nix are bind-mount or symlink
      # Relocate /boot to /nix/persist/boot
      mirroredBoots = [{
        path = "/nix/persist/boot";
        devices = [ "nodev" ];
        efiSysMountPoint = config.boot.loader.efi.efiSysMountPoint;
      }];
    };
  };
}
