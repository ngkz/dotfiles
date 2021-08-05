# configuration for stagingvm

{ config, pkgs, inputs, ... }:
let
  inherit (inputs) self;
in {
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

    kernelModules = [];
    extraModulePackages = [];
  };

  modules.grub-fde.cryptlvmDevice = "/dev/sda2";

  home-manager.users.user.imports = with self.homeManagerModules; [
    tmpfs-as-home
    workstation
    sway-desktop
  ];

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
}
