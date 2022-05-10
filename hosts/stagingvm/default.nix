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
    portable
    workstation
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
  boot.kernelPackages = pkgs.linuxPackages_latest; # Hyper-V DRM Driver
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
  ];

  virtualisation.hypervGuest.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  users.users.user.extraGroups = [
    "video" # KDE wayland software-rendering
  ];
}
