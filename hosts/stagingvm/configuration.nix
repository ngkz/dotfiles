# configuration for stagingvm

{ config, pkgs, ... }: 
{
  networking.hostName = "stagingvm"; # Define your hostname.

  boot = {
    initrd = {
      availableKernelModules = [ "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };

    kernelModules = [];
    extraModulePackages = [];
  };

  boot.initrd.luks.devices."cryptlvm".device = "/dev/sda2";

  virtualisation.virtualbox.guest = {
    enable = true;
    x11 = false;
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;
  networking.interfaces.enp0s8.useDHCP = true;

  home-manager.users.user.imports = [
    ../../home/profiles/workstation.nix
  ];
}
