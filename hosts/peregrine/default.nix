# configuration for peregrine

{ config, lib, pkgs, inputs, ... }:
{
  networking.hostName = "peregrine";

  imports = with inputs.nixos-hardware.nixosModules; [
    ../../modules/agenix.nix
    ../../modules/base
    ../../modules/grub-secureboot
    ../../modules/ssd.nix
    ../../modules/sshd.nix
    ../../modules/workstation
    ../../modules/sway-desktop.nix
    ../../modules/undervolt.nix
    ../../modules/nm-config-home.nix
    ../../modules/vmm.nix
    ../../modules/btrfs-maintenance
    ../../modules/nix-maintenance
    ../../modules/zswap.nix
    ../../modules/bluetooth.nix
    ../../modules/hacking.nix

    ../../modules/profiles/laptop.nix
    common-pc-laptop-acpi_call
    ../../modules/profiles/intel-cpu.nix
    ../../modules/profiles/intel-wifi.nix
  ];

  # hardware configuration
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"

    # LUKS Early boot AES acceleration
    "aesni_intel"
    "cryptd"
    # Btrfs CRC hardware acceleration
    "crc32c-intel"
  ];

  # disk
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true; # tpm2 unlock requires systemd initrd
  boot.initrd.luks.devices."cryptroot" = {
    allowDiscards = true;
    bypassWorkqueues = true;
    device = "/dev/disk/by-uuid/00a3159f-12ca-4600-b730-40427230fe1a";
    crypttabExtraOpts = [ "tpm2-device=auto" ]; # tpm2 unlock
  };

  fileSystems =
    let
      rootDev = "/dev/mapper/cryptroot";
      # only options in first mounted subvolume will take effect so all mounts must have same options
      rootOpts = [ "lazytime" ];
    in
    {
      "/boot" = {
        device = "/dev/disk/by-uuid/9756-0098";
        fsType = "vfat";
      };
      "/nix" = {
        device = rootDev;
        fsType = "btrfs";
        options = rootOpts ++ [ "subvol=nix" "noatime" ];
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
        options = rootOpts ++ [ "subvol=swap" "noatime" ];
      };
      "/var/snapshots" = {
        device = rootDev;
        fsType = "btrfs";
        options = rootOpts ++ [ "subvol=snapshots" "noatime" ];
      };
    };
  swapDevices = [
    {
      device = "/var/swap/swapfile";
      discardPolicy = "once";
    }
  ];

  tmpfs-as-root.enable = true;
  tmpfs-as-root.persistentDirs = [
    # tlp
    "/var/lib/tlp"
  ];

  modules.btrfs-maintenance = {
    fileSystems = [
      # scrubbling one of subvolumes scrubs the whole filesystem
      "/var/persist"
    ];
  };

  environment.systemPackages = with pkgs; [
    nvme-cli # NVMe SSD
    wireguard-tools
  ];

  # user
  age.secrets.user-password-hash-peregrine.file = ../../secrets/user-password-hash-peregrine.age;
  users.users.user.hashedPasswordFile = config.age.secrets.user-password-hash-peregrine.path;

  home-manager.users.user = {
    imports = [
      ../../home/workstation
      ../../home/sway-desktop
      ../../home/hacking
      ../../home/vmm.nix
    ];
  };

  # tlp
  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = 70;
    STOP_CHARGE_THRESH_BAT0 = 80;

    DISK_DEVICES = "nvme0n1";
    #SATA_LINKPWR_ON_AC = "max_performance";

    PLATFORM_PROFILE_ON_AC = "performance";
    PLATFORM_PROFILE_ON_BAT = "low-power";

    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

    CPU_ENERGY_PERF_POLICY_ON_AC = "performance"; # to achieve 4.6GHz single-core boost clock
    CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
    CPU_HWP_DYN_BOOST_ON_AC = 1;
    CPU_HWP_DYN_BOOST_ON_BAT = 0;

    RESTORE_DEVICE_STATE_ON_STARTUP = 1; # TLP masks systemd-rfkill
    DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth wifi wwan";

    RUNTIME_PM_DRIVER_DENYLIST = "";
    PCIE_ASPM_ON_AC = "default";
    PCIE_ASPM_ON_BAT = "powersupersave";
  };

  # hibernation
  boot.resumeDevice = config.fileSystems."/var/swap".device;

  boot.kernelParams = [
    # tlp
    "pcie_aspm=force"

    # hibernation
    "resume_offset=533760"
  ];

  # XXX workaround for swaywm/sway #6962
  environment.variables.WLR_DRM_NO_MODIFIERS = "1";

  # additional network configuration
  environment.etc."NetworkManager/system-connections/F2L-VPN.nmconnection" = {
    source = config.age.secrets."wireguard-peregrine.nmconnection".path;
    mode = "0400";
  };
  age.secrets."wireguard-peregrine.nmconnection".file = ../../secrets/wireguard-peregrine.nmconnection.age;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
