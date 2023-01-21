# configuration for prairie

{ config, lib, pkgs, inputs, ... }:
let
  inherit (inputs) self nixos-hardware;
in
{
  networking.hostName = "prairie";

  imports = with self.nixosModules; with nixos-hardware.nixosModules; [
    base
    grub-secureboot
    ssd
    sshd
    workstation
    sway-desktop
    nm-config-home
    vm

    common-cpu-intel
    common-pc-laptop
  ];

  # hardware configuration
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "sd_mod"
    "sr_mod"
    "rtsx_pci_sdmmc"

    # LUKS Early boot AES acceleration
    "aesni_intel"
    "cryptd"
    # Btrfs CRC hardware acceleration
    "crc32c-intel"
  ];

  # this machine only boot from /Boot/bootx64.efi
  boot.loader.grub.efiInstallAsRemovable = true;

  # disk
  boot.initrd.luks.devices."cryptroot" = {
    allowDiscards = true;
    bypassWorkqueues = true;
    device = "/dev/disk/by-uuid/22294dd8-e616-4d75-849c-eb04ebb64644";
  };

  fileSystems =
    let
      rootDev = "/dev/disk/by-uuid/34f0cfae-4706-4ac0-bc10-6ecd3333fbe5";
      # only options in first mounted subvolume will take effect so all mounts must have same options
      rootOpts = [ "compress=zstd" ];
    in
    {
      "/boot" = {
        device = "/dev/disk/by-uuid/333D-DEF5";
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
        options = rootOpts ++ [ "subvol=persist" "lazytime" ];
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
  modules.tmpfs-as-root.storage = "/var/persist";
  services.btrfs.autoScrub = {
    enable = true;
    # scrubbling subvolumes scrubs the whole filesystem
    fileSystems = [ "/var/persist" ];
  };

  # intel cpu
  hardware.enableRedistributableFirmware = true;
  boot.kernelModules = [ "kvm-intel" ];

  # bluetooth
  hardware.bluetooth.enable = true;
  systemd.services.bluetooth.serviceConfig = {
    StateDirectory = "";
    ReadWritePaths = [
      "/var/lib/bluetooth"
      "${config.modules.tmpfs-as-root.storage}/var/lib/bluetooth"
    ];
  };

  environment.systemPackages = with pkgs; [
    intel-gpu-tools # intel_gpu_top
  ];

  home-manager.users.user = {
    imports = with self.homeManagerModules; [
      tmpfs-as-home
      workstation
      sway-desktop
    ];
  };

  # tlp
  # FIXME ASPM is not working, even with pcie_aspm=force
  services.tlp.settings = {
    STOP_CHARGE_THRESH_BAT0 = 50;

    DISK_DEVICES = "sda";

    CPU_SCALING_GOVERNOR_ON_AC = "performance"; # this machine refuses to run at high clock when governor is powersave
    CPU_SCALING_GOVERNOR_ON_BAT = "performance";

    RESTORE_DEVICE_STATE_ON_STARTUP = 1; # TLP masks systemd-rfkill
    DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth wifi wwan";

    RUNTIME_PM_DRIVER_DENYLIST = "";
    PCIE_ASPM_ON_AC = "default";
    PCIE_ASPM_ON_BAT = "powersupersave";
  };

  boot.extraModprobeConfig = ''
    options iwlwifi power_save=1 uapsd_disable=0
    options iwldvm force_cam=0

    options i915 enable_fbc=1
    options drm vblankoffdelay=1
  '';

  modules.tmpfs-as-root.persistentDirs = [
    # bluetooth
    "/var/lib/bluetooth"
    # tlp
    "/var/lib/tlp"
  ];

  # hibernation
  boot.resumeDevice = config.fileSystems."/var/swap".device;

  boot.kernelParams = [
    # tlp
    "pcie_aspm=force"

    # hibernation
    "resume_offset=533760"
  ];
}
