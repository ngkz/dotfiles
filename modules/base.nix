# configuration applied to all hosts

{ pkgs, ... }:
{
  imports = [
    ./tmpfs-as-root.nix
    ./nix.nix
    ./users.nix
    ./sudo.nix
    ./home-manager.nix
    ./sysctl-tweaks.nix
    ./mdns.nix
    ./update-users-groups-bug-workaround
  ];

  config = {
    # Select internationalisation properties.
    i18n.defaultLocale = "ja_JP.UTF-8";

    # Set your time zone.
    time.timeZone = "Asia/Tokyo";

    # tmpfs /tmp
    boot.tmp.useTmpfs = true;

    # List packages installed in system profile. To search, run:
    # $ nix search nixpkgs wget
    environment.systemPackages = with pkgs; [
      btrfs-progs
      compsize
      ntfs3g
      e2fsprogs
      ntfsprogs
      hddtemp
      lm_sensors
      parted
      smartmontools #smartctl
      termshark
      usbutils #lsusb
      efibootmgr
      sdparm
      hdparm
      sysfsutils #systool
      lshw
      dmidecode
      pciutils #lspci
      ddrescue
      bmap-tools
    ];

    services.udev.extraRules = ''
      # set scheduler for NVMe SSD
      ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
      # set scheduler for SATA SSD and eMMC
      ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
      # set scheduler for rotating disks
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
    '';

    # record machine-check exception
    hardware.rasdaemon.enable = true;
  };
}
