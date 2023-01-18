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

  # hardware configuration
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  boot.initrd.availableKernelModules = [
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

  # disk
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."cryptroot" = {
    allowDiscards = true;
    bypassWorkqueues = true;
    device = "/dev/disk/by-partlabel/NixOS";
  };
  fileSystems =
    let
      rootDev = "/dev/mapper/cryptroot";
      rootOpts = [ "compress=zstd" ];
    in
    {
      "/boot" = {
        label = "ESP";
        fsType = "vfat";
      };
      "/nix" = {
        device = rootDev;
        fsType = "btrfs";
        # only options in first mounted subvolume will take effect
        options = rootOpts ++ [ "subvol=nix" ];
      };
      "/var/persist" = {
        device = rootDev;
        fsType = "btrfs";
        neededForBoot = true;
        options = rootOpts ++ [ "subvol=persist" ];
      };
      "/var/swap" = {
        device = rootDev;
        fsType = "btrfs";
        options = rootOpts ++ [ "subvol=swap" ];
      };
      "/var/snapshots" = {
        device = rootDev;
        fsType = "btrfs";
        options = rootOpts ++ [ "subvol=snapshots" ];
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
