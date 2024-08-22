# configuration applied to all hosts

{ config, lib, pkgs, utils, inputs, ... }:
let
  inherit (lib) mapAttrs filterAttrs mapAttrsToList mkIf;
  inherit (inputs) self home-manager;
in
{
  imports = [
    home-manager.nixosModule
    ../tmpfs-as-root.nix
  ];

  config = {
    nixpkgs = import ../../nixpkgs.nix inputs;

    # Enable experimental flakes feature
    nix = {
      # Enable flake
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes

        # Keep build-time dependencies when GC
        # keep-outputs = true
        # keep-derivations = true
      '';

      settings = {
        # Only allow administrative users to connect the nix daemon
        allowed-users = [ "root" "@wheel" ];

        trusted-users = [ "root" ];

        # max-jobs = 1; # XXX default max-jobs causes memory exhaustion

        # substituters = [
        #   "http://peregrine.local:5000"
        # ];

        trusted-public-keys = [
          "peregrine:ttyus2jSLVWOMNfGkwgC71iJ36DZgJINICtkdUMeg8k="
        ];
      };

      # turned autoOptimiseStore and gc.automatic off due to slowdown
    };

    # Let 'nixos-version --json' know the Git revision of this flake.
    system.configurationRevision = mkIf (self ? rev) self.rev;

    # build packages on the disk
    systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";

    # Select internationalisation properties.
    i18n.defaultLocale = "ja_JP.UTF-8";

    # Set your time zone.
    time.timeZone = "Asia/Tokyo";

    # tmpfs /tmp
    boot.tmp.useTmpfs = true;

    # User accounts
    users = {
      mutableUsers = false;

      users = {
        # disable root login
        root.hashedPassword = "*";

        # define a primary user account
        user = {
          isNormalUser = true;
          uid = 1000;
          extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
          shell = pkgs.zsh;
        };
      };
    };

    # sudo
    security.sudo = {
      execWheelOnly = true;
      extraConfig = ''
        # rollback results in sudo lectures after each reboot
        Defaults lecture = never
      '';
    };

    # home-manager
    home-manager = {
      useGlobalPkgs = true; # use global nixpkgs
      # install per-user packages to /etc/profiles to make nixos-rebuild build-vm work
      useUserPackages = true;
      users.user = { osConfig, config, lib, ... }: {
        imports = [
          ../../home/nixos.nix
          ../../home/base.nix
          ../../home/cli-base.nix
          ../../home/tmpfs-as-home.nix
        ];
      };
      extraSpecialArgs = {
        inherit inputs;
        lib = lib.extend (_: _: home-manager.lib);
      };
    };

    environment.pathsToLink = [ "/share/zsh" ]; #zsh

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

      # disable usb keyboard wakeup
      ATTR{idProduct}=="6047",ATTR{idVendor}=="17ef",ATTR{power/wakeup}="disabled"
    '';

    # XXX Apply home.sessionPath when logging in via ssh
    programs.zsh.enable = true;

    # XXX Apply home.sessionVariables. Workaround for home-manager #1011
    environment.extraInit = ''
      if [ -e "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
        . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
      fi
    '';

    # use bbr congestion control algorithm
    boot.kernelModules = [ "tcp_bbr" ];
    boot.kernel.sysctl = {
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "cake";
      "net.ipv4.tcp_notsent_lowat" = 16384;

      # XXX x86-64
      "vm.mmap_rnd_bits" = 32;
      "vm.mmap_rnd_compat_bits" = 16;
    };

    # mDNS
    services.avahi = {
      enable = true;
      nssmdns4 = true; # *.local resolution
      publish = {
        enable = true;
        addresses = true; # make this host accessible with <hostname>.local
        workstation = true;
      };
    };

    # record machine-check exception
    hardware.rasdaemon.enable = true;

    # XXX temporary workaround for https://github.com/NixOS/nixpkgs/pull/273758
    system.activationScripts.users.text =
      with lib;
      let
        cfg = config.users;
        spec = pkgs.writeText "users-groups.json" (builtins.toJSON {
          inherit (cfg) mutableUsers;
          users = mapAttrsToList
            (_: u:
              {
                inherit (u)
                  name uid group description home homeMode createHome isSystemUser
                  password hashedPasswordFile hashedPassword
                  autoSubUidGidRange subUidRanges subGidRanges
                  initialPassword initialHashedPassword expires;
                shell = utils.toShellPath u.shell;
              })
            cfg.users;
          groups = attrValues cfg.groups;
        });
      in
      lib.mkForce ''
        install -m 0700 -d /root
        install -m 0755 -d /home

        ${pkgs.perl.withPackages (p: [ p.FileSlurp p.JSON ])}/bin/perl \
        -w ${./update-users-groups.pl} ${spec}
      '';
  };
}
