# configuration for stagingvm

{ config, pkgs, inputs, ... }:
let
  inherit (inputs) self;
in
{
  networking.hostName = "stagingvm";

  imports = with self.nixosModules; [
    base
    grub-fde
    ssd
    sshd
    workstation
    sway-desktop
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };

    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  # Hyper-V DRM driver
  boot.blacklistedKernelModules = [ "hyperv_fb" ];
  environment.variables.WLR_RENDERER_ALLOW_SOFTWARE = "1";

  modules.grub-fde = {
    cryptlvmDevice = "/dev/sda2";
    espDevice = "/dev/disk/by-label/ESP";
  };
  modules.tmpfs-as-root.storeFS = {
    label = "nix";
    fsType = "xfs";
  };
  swapDevices = [
    {
      label = "swap";
      discardPolicy = "once";
    }
  ];

  home-manager.users.user.imports = with self.homeManagerModules; [
    tmpfs-as-home
    workstation
    sway-desktop
  ];

  virtualisation.hypervGuest.enable = true;

  # Hyper-V NIC doesn't support MAC raodnomization
  environment.etc."NetworkManager/system-connections/eth0.nmconnection" = {
    source = ./eth0.nmconnection;
    mode = "0400";
  };
}
