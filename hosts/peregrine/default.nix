# configuration for peregrine

{ config, pkgs, inputs, ... }:
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
    intel-undervolt

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
  modules.tmpfs-as-root.persistentDirs = [ "/var/lib/bluetooth" ];

  # undervolting and stopping thermal/power throttling
  services.intel-undervolt = {
    enable = true;
    extraConfig = builtins.readFile ./intel-undervolt.conf;
  };
  systemd.services.intel-undervolt-loop.enable = false;

  # increase maximum fan speed
  services.thinkfan = {
    enable = true;
    levels = [
      [ "level auto" 0 70 ]
      [ "level full-speed" 65 32767 ]
    ];
  };

  # power management
  powerManagement.cpuFreqGovernor = "powersave";

  boot.kernelParams = [
    # power saving
    "pcie_aspm=force"
  ];

  environment.systemPackages = with pkgs; [
    nvme-cli # NVMe SSD
    intel-gpu-tools # intel_gpu_top
  ];

  home-manager.users.user.imports = with self.homeManagerModules; [
    tmpfs-as-home
    workstation
    sway-desktop
  ];

  # Network
  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;
  #TODO wireless network
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Whiskey Lake is not affected by L1TF and Meltdown
  modules.hardening.disableMeltdownAndL1TFMitigation = true;
}
