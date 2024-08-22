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
  };
}
