# configuration for peregrine

{ config, lib, pkgs, ... }:
{
  networking.hostName = "peregrine";

  imports = [
    ../../modules/agenix.nix
    ../../modules/base.nix
    ../../modules/grub-secureboot
    ../../modules/ssd.nix
    ../../modules/sshd.nix
    ../../modules/workstation.nix
    ../../modules/backup
    # ../../modules/print-and-scan.nix
    ../../modules/gnome.nix
    ../../modules/undervolt
    ../../modules/vmm.nix
    ../../modules/btrfs-maintenance
    ../../modules/zswap.nix
    ../../modules/bluetooth.nix
    ../../modules/network-manager
    ../../modules/binary-cache.nix
    ../../modules/disable-usb-keyboard-wakeup.nix
    ../../modules/tailscale/client.nix
    ../../modules/syncthing-user.nix
    ../../modules/btrbk.nix
    ../../modules/upower.nix
    ../../modules/gpg.nix
    ../../modules/ssh.nix
    ../../modules/mail.nix
    ../../modules/laptop.nix
    ../../modules/intel-cpu.nix
    ../../modules/intel-wifi.nix
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

  hardware.trackpoint = {
    enable = true;
    speed = 255;
    device = "TPPS/2 Elan Trackpoint";
  };

  # increase maximum fan speed
  services.thinkfan = {
    enable = true;
    levels = [
      [ "level auto" 0 80 ]
      [ "level full-speed" 65 32767 ]
    ];
  };

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

  modules.btrfs-maintenance = {
    fileSystems = [
      # scrubbling one of subvolumes scrubs the whole filesystem
      "/var/persist"
    ];
  };

  environment.systemPackages = with pkgs; [
    nvme-cli # NVMe SSD
    linux-wifi-hotspot
  ];

  # user
  age.secrets.user-password-hash-peregrine.file = ../../secrets/user-password-hash-peregrine.age;
  users.users.user.hashedPasswordFile = config.age.secrets.user-password-hash-peregrine.path;

  home-manager.users.user.imports = [
    ../../home/workstation.nix
    ../../home/ssh.nix
    ../../home/gnome
    ../../home/hacking
    ../../home/vmm.nix
    ../../home/tailscale.nix
    ../../home/mail.nix
    ../../home/syncthing.nix
    ../../home/signal
    ../../home/gpg
  ];

  # tlp
  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = 70;
    STOP_CHARGE_THRESH_BAT0 = 80;

    PLATFORM_PROFILE_ON_AC = "performance";
    PLATFORM_PROFILE_ON_BAT = "low-power";

    CPU_ENERGY_PERF_POLICY_ON_AC = "84"; # to achieve 4.6GHz single-core boost clock
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

  network-manager.connections = [
    "parents-home-1f-a"
    "parents-home-1f-g"
    "parents-home-2f"
    "phone"
    "0000docomo"
    "IBARAKI-FREE-Wi-Fi"
    "home-a"
    "PD-50"
  ];

  undervolt = {
    cpu = -105;
    gpu = -65;
    cpuCache = -65;
    gpuUnslice = -65;
    systemAgent = -15;

    shortTermPowerLimit = 65;
    longTermPowerLimit = 65;

    tjoffset = -3;
  };

  # sshd
  services.openssh.openFirewall = false;
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = config.services.openssh.ports; # tailscale only

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
