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

    # LUKS Early boot AES acceleration
    "aesni_intel"
    "cryptd"
    # Btrfs CRC hardware acceleration
    "crc32c-intel"
  ];

  # AMD CPU
  hardware.enableRedistributableFirmware = true;
  boot.kernelModules = [ "kvm-amd" ];
}
