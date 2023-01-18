# configuration for stagingvm

{ config, pkgs, inputs, ... }:
let
  inherit (inputs) self;
in
{
  networking.hostName = "stagingvm";

  imports = with self.nixosModules; [
    base
    efistub-secureboot
    ssd
    sshd
    workstation
    sway-desktop

    "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "ohci_pci"
        "ehci_pci"
        "ahci"
        "sd_mod"
        "sr_mod"

        # Early boot AES acceleration
        "aesni_intel"
        "cryptd"
        # Btrfs CRC hardware acceleration
        "crc32c-intel"
      ];
    };

    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  # disk
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."cryptroot" = {
    allowDiscards = true;
    bypassWorkqueues = true;
    device = "/dev/disk/by-partlabel/NixOS";
  };
  fileSystems = {
    "/boot" = {
      label = "ESP";
      fsType = "vfat";
    };
    "/nix" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      # only options in first mounted subvolume will take effect
      options = [ "compress=zstd" "subvol=nix" ];
    };
    "/var/persist" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      neededForBoot = true;
      options = [ "compress=zstd" "subvol=persist" ];
    };
    "/var/swap" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "compress=zstd" "subvol=swap" ];
    };
    "/var/snapshots" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "compress=zstd" "subvol=snapshots" ];
    };
  };
  swapDevices = [
    {
      device = "/var/swap/swapfile";
      discardPolicy = "once";
    }
  ];
  modules.tmpfs-as-root.storage = "/var/persist";

  home-manager.users.user.imports = with self.homeManagerModules; [
    tmpfs-as-home
    workstation
    sway-desktop
  ];

  # Hyper-V
  virtualisation.hypervGuest.enable = true;

  # Hyper-V DRM driver
  boot.blacklistedKernelModules = [ "hyperv_fb" ];
  environment.variables.WLR_RENDERER_ALLOW_SOFTWARE = "1";

  # Hyper-V NIC doesn't support MAC raodnomization
  environment.etc."NetworkManager/system-connections/eth0.nmconnection" = {
    source = ./eth0.nmconnection;
    mode = "0400";
  };

  # QEMU
  services.qemuGuest.enable = true;
}
