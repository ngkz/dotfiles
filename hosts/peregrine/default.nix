# configuration for peregrine

{ config, lib, pkgs, inputs, ... }:
let
  inherit (inputs) self nixos-hardware;
in
{
  networking.hostName = "peregrine";

  imports = with self.nixosModules; with nixos-hardware.nixosModules; [
    base
    efistub-secureboot
    ssd
    sshd
    workstation
    sway-desktop
    undervolt
    nm-config-home
    vm
    btrfs-maintenance
    nix-maintenance

    common-cpu-intel
    common-pc-laptop
    common-pc-laptop-acpi_call
  ];

  # hardware configuration
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"

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
    device = "/dev/disk/by-uuid/00a3159f-12ca-4600-b730-40427230fe1a";
    crypttabExtraOpts = [ "tpm2-device=auto" ]; # tpm2 unlock
  };

  fileSystems =
    let
      rootDev = "/dev/mapper/cryptroot";
      # only options in first mounted subvolume will take effect so all mounts must have same options
      rootOpts = [ "lazytime" ];
    in
    {
      "/boot" = {
        device = "/dev/disk/by-uuid/9756-0098";
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
  modules.tmpfs-as-root.storage = "/var/persist";
  modules.btrfs-maintenance = {
    defragMounts = [
      "/var/persist"
      "/var/persist/home"
    ];
    fileSystems = [
      # scrubbling one of subvolumes scrubs the whole filesystem
      "/var/persist"
    ];
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
    nvme-cli # NVMe SSD
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
  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = 70;
    STOP_CHARGE_THRESH_BAT0 = 80;

    DISK_DEVICES = "nvme0n1";
    #SATA_LINKPWR_ON_AC = "max_performance";

    PLATFORM_PROFILE_ON_AC = "performance";
    PLATFORM_PROFILE_ON_BAT = "low-power";

    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

    CPU_ENERGY_PERF_POLICY_ON_AC = "performance"; # to achieve 4.6GHz single-core boost clock
    CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
    CPU_HWP_DYN_BOOST_ON_AC = 1;
    CPU_HWP_DYN_BOOST_ON_BAT = 0;

    RESTORE_DEVICE_STATE_ON_STARTUP = 1; # TLP masks systemd-rfkill
    DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth wifi wwan";

    RUNTIME_PM_DRIVER_DENYLIST = "";
    PCIE_ASPM_ON_AC = "default";
    PCIE_ASPM_ON_BAT = "powersupersave";
  };

  # power saving
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=1 uapsd_disable=0
    options iwlmvm power_scheme=3

    options i915 enable_dc=2 enable_fbc=1 enable_psr=1 enable_guc=3 enable_psr2_sel_fetch=1 enable_dpcd_backlight=1
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

  # XXX workaround for swaywm/sway #6962
  environment.variables.WLR_DRM_NO_MODIFIERS = "1";
}
