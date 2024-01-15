# configuration for noguchi-pc

{ config, lib, pkgs, ... }:
let
  inherit (lib) mkAfter;
in
{
  networking.hostName = "noguchi-pc";

  imports = [
    ../../modules/agenix.nix
    ../../modules/base
    ../../modules/grub-secureboot
    ../../modules/ssd.nix
    ../../modules/workstation
    ../../modules/sway-desktop.nix
    ../../modules/vmm.nix
    ../../modules/btrfs-maintenance
    ../../modules/nix-maintenance
    ../../modules/zswap.nix
    ../../modules/bluetooth.nix
    ../../modules/hacking.nix

    ../../modules/profiles/laptop.nix
    ../../modules/profiles/intel-cpu.nix
    ../../modules/profiles/intel-wifi.nix
  ];

  # hardware configuration
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usbhid"
    "sd_mod"
    "sr_mod"

    # LUKS Early boot AES acceleration
    "aesni_intel"
    "cryptd"
    # Btrfs CRC hardware acceleration
    "crc32c-intel"
  ];

  # disk
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true; # tpm2 unlock requires systemd initrd
  boot.initrd.luks.devices."cryptroot" = {
    allowDiscards = true;
    bypassWorkqueues = true;
    device = "/dev/disk/by-uuid/7583af88-a565-4147-896e-65ad697a0f87";
    crypttabExtraOpts = [ "tpm2-device=auto" ]; # tpm2 unlock
  };

  fileSystems =
    let
      rootDev = "/dev/mapper/cryptroot";
      # only options in first mounted subvolume will take effect so all mounts must have same options
      rootOpts = [ "compress=zstd:1" "lazytime" ];
    in
    {
      "/boot" = {
        device = "/dev/disk/by-uuid/24B3-7A55";
        fsType = "vfat";
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
    };
  swapDevices = [
    {
      device = "/var/swap/swapfile";
      discardPolicy = "once";
    }
  ];

  modules.tmpfs-as-root.enable = true;
  modules.tmpfs-as-root.persistentDirs = [
    # tlp
    "/var/lib/tlp"
  ];

  modules.btrfs-maintenance = {
    fileSystems = [
      # scrubbling one of subvolumes scrubs the whole filesystem
      "/var/persist"
    ];
  };

  # user
  age.secrets.user-password-hash-noguchi-pc.file = ../../secrets/user-password-hash-noguchi-pc.age;
  users.users.user.hashedPasswordFile = config.age.secrets.user-password-hash-noguchi-pc.path;

  home-manager.users.user = {
    imports = [
      ../../home/workstation
      ../../home/sway-desktop
      ../../home/hacking
      ../../home/vmm.nix
    ];
  };

  # tlp
  services.tlp.settings = {
    DISK_DEVICES = "sda";

    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

    CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
    CPU_HWP_DYN_BOOST_ON_AC = 1;
    CPU_HWP_DYN_BOOST_ON_BAT = 0;

    RESTORE_DEVICE_STATE_ON_STARTUP = 1; # TLP masks systemd-rfkill
    DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth wifi wwan";

    # XXX iGPU lockup
    # RUNTIME_PM_DRIVER_DENYLIST = "";
    # PCIE_ASPM_ON_AC = "default";
    # PCIE_ASPM_ON_BAT = "powersupersave";
  };

  # XXX disable guc submission. It looks like iGPU causing lockup sometimes
  profiles.intel-cpu.enableGPUPowerSaving = false;

  # hibernation
  boot.resumeDevice = config.fileSystems."/var/swap".device;

  boot.kernelParams = [
    # tlp
    # XXX iGPU lockup
    # "pcie_aspm=force"

    # hibernation
    "resume_offset=533760"
  ];

  # additional network configuration
  environment.etc."NetworkManager/system-connections/IFC.nmconnection" = {
    source = config.age.secrets."IFC.nmconnection".path;
    mode = "0400";
  };
  age.secrets."IFC.nmconnection".file = ../../secrets/IFC.nmconnection.age;

  environment.etc."NetworkManager/system-connections/F2L-VPN.nmconnection" = {
    source = config.age.secrets."wireguard-noguchi-pc.nmconnection".path;
    mode = "0400";
  };
  age.secrets."wireguard-noguchi-pc.nmconnection".file = ../../secrets/wireguard-noguchi-pc.nmconnection.age;

  environment.systemPackages = with pkgs; [ wireguard-tools ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
