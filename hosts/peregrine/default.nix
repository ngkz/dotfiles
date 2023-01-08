# configuration for peregrine

{ config, lib, pkgs, inputs, ... }:
let
  inherit (inputs) self nixos-hardware;
in
{
  networking.hostName = "peregrine";

  imports = with self.nixosModules; with nixos-hardware.nixosModules; [
    base
    grub-fde
    ssd
    sshd
    portable
    workstation
    sway-desktop
    undervolt
    nm-config-home
    vm

    common-cpu-intel
    common-pc-laptop
    common-pc-laptop-acpi_call
  ];

  # hardware configuration
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" ];

  # disk
  modules.grub-fde = {
    cryptlvmDevice = "/dev/disk/by-uuid/e0b18f6c-fd58-45bc-a552-a5eec648b34a";
    espDevice = "/dev/disk/by-uuid/AC8A-0C4E";
  };
  modules.tmpfs-as-root.storeFS = {
    device = "/dev/disk/by-uuid/d3fd2c64-440a-49a3-9299-eeee16da500e";
    fsType = "xfs";
  };
  swapDevices = [
    {
      device = "/dev/disk/by-uuid/bf4f7d52-b93c-4318-8c9f-f5c50f492084";
      discardPolicy = "once";
    }
  ];

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

  # power management
  powerManagement.cpuFreqGovernor = "powersave";

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

  # Whiskey Lake is not affected by L1TF and Meltdown
  modules.hardening.disableMeltdownAndL1TFMitigation = true;

  # tlp
  boot.kernelParams = [
    # enable ASPM
    "pcie_aspm=force"
  ];

  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = 70;
    STOP_CHARGE_THRESH_BAT0 = 80;

    DISK_DEVICES = "nvme0n1";
    #SATA_LINKPWR_ON_AC = "max_performance";

    PLATFORM_PROFILE_ON_AC = "performance";
    PLATFORM_PROFILE_ON_BAT = "low-power";

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

  boot.extraModprobeConfig = ''
    options iwlwifi power_save=1 uapsd_disable=0
    options iwlmvm power_scheme=3
    #options iwldvm force_cam=0

    options i915 enable_dc=2 enable_fbc=1 enable_psr=1 enable_guc=3 enable_psr2_sel_fetch=1 enable_dpcd_backlight=1
    options drm vblankoffdelay=1
  '';

  modules.tmpfs-as-root.persistentDirs = [
    # bluetooth
    "/var/lib/bluetooth"
    # tlp
    "/var/lib/tlp"
  ];

  # XXX workaround for swaywm/sway #6962
  environment.variables.WLR_DRM_NO_MODIFIERS = "1";
}
