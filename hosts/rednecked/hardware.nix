{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  nixpkgs.hostPlatform = mkDefault "x86_64-linux";
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "sd_mod"
    "bcache"

    # Btrfs CRC hardware acceleration
    "crc32c-intel"
  ];

  # AMD CPU
  hardware.enableRedistributableFirmware = true;
  boot.kernelModules = [ "kvm-amd" ];

  # record machine-check exception
  hardware.rasdaemon.enable = true;
}
