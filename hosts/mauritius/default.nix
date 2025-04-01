{ config, pkgs, lib, ... }:

{
  networking.hostName = "mauritius";

  imports = [
    ../../modules/agenix.nix
    ../../modules/base.nix
    ../../modules/workstation.nix
    ../../modules/gnome.nix
    # ../../modules/btrfs-maintenance
    ../../modules/zswap.nix
    ../../modules/network-manager
    ../../modules/tailscale/client.nix
    ../../modules/syncthing-user.nix
    ../../modules/btrbk.nix
    # ../../modules/ssh.nix
  ];

  # hardware configuration
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  virtualisation.vmware.guest.enable = true;
  boot.initrd.availableKernelModules = [
    "sd_mod"

    # Btrfs CRC hardware acceleration
    "crc32c-intel"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  powerManagement.enable = false; #VM

  # disk
  # legacy boot
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  system.fsPackages = [ pkgs.open-vm-tools ];
  fileSystems =
    let
      rootDev = "/dev/sda1";
      # only options in first mounted subvolume will take effect so all mounts must have same options
      rootOpts = [ "compress=zstd:1" "lazytime" ];
    in
    {
      "/boot" = {
        device = rootDev;
        fsType = "btrfs";
        options = rootOpts ++ [ "subvol=boot" ];
      };
      "/nix" = {
        device = rootDev;
        fsType = "btrfs";
        options = rootOpts ++ [ "subvol=nix" "noatime" ];
      };
      "/var/persist" = {
        device = rootDev;
        fsType = "btrfs";
        neededForBoot = true;
        options = rootOpts ++ [ "subvol=persist" ];
      };
      "/var/swap" = {
        device = rootDev;
        fsType = "btrfs";
        options = rootOpts ++ [ "subvol=swap" "noatime" ];
      };
      "/var/snapshots" = {
        device = rootDev;
        fsType = "btrfs";
        options = rootOpts ++ [ "subvol=snapshots" "noatime" ];
      };
      "/home/user/host" = {
        device = ".host:/nixos";
        fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
        options = [
          "umask=22"
          "uid=${toString config.users.users.user.uid}"
          "gid=${toString config.users.groups."${config.users.users.user.group}".gid}"
          "allow_other"
          "auto_unmount"
        ];
      };
    };
  swapDevices = [
    {
      device = "/var/swap/swapfile";
      discardPolicy = "once";
    }
  ];

  tmpfs-as-root.enable = true;

  # user
  age.secrets.user-password-hash-mauritius.file = ../../secrets/user-password-hash-mauritius.age;
  users.users.user.hashedPasswordFile = config.age.secrets.user-password-hash-mauritius.path;

  home-manager.users.user = {
    imports = [
      ../../home/workstation.nix
      ../../home/gnome
      ../../home/hacking
      ../../home/tailscale.nix
      ../../home/syncthing.nix
      # ../../home/ssh.nix
    ];

    dconf.settings = {
      "org/gnome/settings-daemon-plugins/color" = {
        night-light-enabled = false;
      };

      "org/gnome/desktop/session" = {
        idle-delay = lib.gvariant.mkUint32 0; # disable automatic screen lock
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
