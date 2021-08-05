# configuration for stagingvm

{ config, pkgs, ... }: 
{
  boot = {
    initrd = {
      availableKernelModules = [ "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };

    kernelModules = [];
    extraModulePackages = [];
  };

  f2l.portable = true;
  f2l.ssd = true;
  f2l.sshd = true;
  f2l.workstation = true;
  f2l.fde.cryptlvmDevice = "/dev/sda2";

  home-manager.users.user = { ... }: {
    f2l.workstation = true;
    f2l.swayDesktop = true;
  };

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
