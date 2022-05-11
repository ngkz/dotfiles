# configuration for peregrine

{ config, pkgs, inputs, ... }:
let
  inherit (inputs) self;
in
{
  networking.hostName = "peregrine";

  imports = with self.nixosModules; [
    base
    grub-fde
    ssd
    sshd
    portable
    workstation
    sway-desktop
  ];

  # Hardware Configuration
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [ "pcie_aspm=force" ]; # power saving
  boot.extraModulePackages = [ ];

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

  powerManagement.cpuFreqGovernor = "powersave";

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.bluetooth.enable = true;
  modules.tmpfs-as-root.persistentDirs = [ "/var/lib/bluetooth" ];

  #TODO nixos-hardware

  # undervolting
  # TODO
  services.undervolt = {
    enable = true;
    coreOffset = 0;
    gpuOffset = 0;
    analogioOffset = 0;
    p1 = {
      limit = 65;
      window = 99;
    };
  };

  # NVMe SSD
  environment.systemPackages = with pkgs; [
    nvme-cli
  ];

  home-manager.users.user.imports = with self.homeManagerModules; [
    tmpfs-as-home
    workstation
    sway-desktop
  ];

  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;
  #TODO wireless network
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
}
