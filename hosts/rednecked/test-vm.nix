{ config, pkgs, inputs, lib, ... }:
let
  inherit (inputs) self;
  inherit (lib) mkForce mkAfter;
in
{
  imports = with self.nixosModules; [
    libvirt-vm
  ];

  modules.libvirt-vm = {
    memorySize = 2048;

    disks = {
      vda = {
        volume = "rednecked-ssd.qcow2";
        capacity = 16384;
      };
      vdb = {
        volume = "rednecked-hdd.qcow2";
        capacity = 16384;
      };
    };

    fileSystems = config.modules.tmpfs-as-root.fileSystems // (import ./fs/fileSystems.nix {
      bootDev = "/dev/vda1";
      rootDev = "/dev/vda2";
      hddDev = "/dev/bcache0";
    });

    sharedDirectories = {
      secrets = {
        source = "/run/rednecked-secrets";
        target = "${config.modules.tmpfs-as-root.storage}/secrets";
        neededForBoot = true;
      };
    };

    extraCreateVMCommands = ''
      /run/wrappers/bin/sudo mkdir -p /run/rednecked-secrets
      /run/wrappers/bin/sudo touch /run/rednecked-secrets/age.key
      /run/wrappers/bin/sudo chmod 640 /run/rednecked-secrets/age.key
      /run/wrappers/bin/sudo chown root:qemu-libvirtd /run/rednecked-secrets/age.key
      (${pkgs.libsecret}/bin/secret-tool lookup agenix rednecked || (echo "couldn't lookup agenix key" >&2 && exit 1)) | /run/wrappers/bin/sudo tee /run/rednecked-secrets/age.key >/dev/null
    '';

    extraDestroyVMCommands = ''
      /run/wrappers/bin/sudo rm -rf /run/rednecked-secrets
    '';

    shareMode = "9p"; # virtiofs doesn't work with hardened profile

    variant = {
      boot.initrd.extraUtilsCommands = ''
        copy_bin_and_libs ${pkgs.btrfs-progs}/bin/mkfs.btrfs
        copy_bin_and_libs ${pkgs.btrfs-progs}/bin/btrfs
        copy_bin_and_libs ${pkgs.dosfstools}/bin/mkfs.fat
        copy_bin_and_libs ${pkgs.parted}/bin/parted
        copy_bin_and_libs ${pkgs.bcache-tools}/bin/make-bcache
      '';
      boot.initrd.postDeviceCommands = ''
        if [ ! -e /dev/bcache0 ]; then
          parted /dev/vda -- mklabel gpt
          parted /dev/vda -- mkpart ESP fat32 1MiB 512MiB
          parted /dev/vda -- set 1 esp on
          parted /dev/vda -- mkpart NixOS 512MiB 100%

          parted /dev/vdb -- mklabel gpt
          parted /dev/vdb -- mkpart spinningrust-back 1MiB 100%

          mkfs.fat -n ESP -F32 /dev/vda1
          mkfs.btrfs -L NixOS /dev/vda2

          mkdir /tmp/mnt
          mount /dev/vda2 /tmp/mnt
          btrfs subvolume create /tmp/mnt/nix
          btrfs subvolume create /tmp/mnt/persist
          btrfs subvolume create /tmp/mnt/swap
          btrfs subvolume create /tmp/mnt/snapshots

          # Create directories for persistent storage
          mkdir -p /tmp/mnt/persist/var/log

          # Create swapfile
          btrfs filesystem mkswapfile --size 2G /tmp/mnt/swap/swapfile

          umount /tmp/mnt
          rmdir /tmp/mnt

          make-bcache -B /dev/vdb1
          modprobe bcache
          echo /dev/vdb1 >/sys/fs/bcache/register_quiet
          mkfs.btrfs -L spinningrust /dev/bcache0
        fi
      '';

      #boot.kernelParams = [ "boot.shell_on_fail" ];

      #Use DHCP
      systemd.network.networks = {
        "30-eth0" = {
          matchConfig.Name = "eth0";
          networkConfig.Bridge = "lanbr0";
          linkConfig.RequiredForOnline = "enslaved";
        };
        "40-lanbr0" = mkForce {
          matchConfig.Name = "lanbr0";
          DHCP = "ipv4";
          linkConfig.RequiredForOnline = "routable";
        };
      };

      # allow passwordless sudo
      security.sudo.wheelNeedsPassword = false;
    };
  };
}
