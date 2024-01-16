# configuration applied to all hosts

{ config, lib, pkgs, utils, inputs, ... }:
let
  inherit (lib) mapAttrs filterAttrs mapAttrsToList mkIf types mkOption;
  inherit (inputs) self home-manager;
in
{
  imports = [
    home-manager.nixosModule
    ../tmpfs-as-root.nix
  ];

  options.modules.base.pythonPackages = mkOption {
    type = with types; functionTo (listOf package);
    default = (_: [ ]);
  };

  config = {
    nixpkgs = import ../../nixpkgs.nix inputs;

    # Enable experimental flakes feature
    nix =
      let
        filteredInputs = filterAttrs (n: _: n != "self") inputs;
        nixPathInputs = mapAttrsToList (n: v: "${n}=${v}") filteredInputs;
        registryInputs = mapAttrs (_: v: { flake = v; }) filteredInputs;
      in
      {
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
        };

        # turned autoOptimiseStore and gc.automatic off due to slowdown

        # It’s often convenient to pin the nixpkgs flake to the exact version
        # of nixpkgs used to build the system. This ensures that commands
        # like nix shell nixpkgs#<package> work more efficiently since
        # many or all of the dependencies of <package> will already be
        # present.
        registry = registryInputs // { dotfiles.flake = inputs.self; };

        nixPath = nixPathInputs ++ [
          "dotfiles=${inputs.self}"
        ];
      };

    # Let 'nixos-version --json' know the Git revision of this flake.
    system.configurationRevision = mkIf (self ? rev) self.rev;

    # Select internationalisation properties.
    i18n.defaultLocale = "ja_JP.UTF-8";

    # Remap Caps Lock To Ctrl
    console.useXkbConfig = true;
    services.xserver = {
      layout = "jp";
      xkbOptions = "ctrl:nocaps";
    };

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
      #execWheelOnly = true; # btrbk can't run with this option
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
      users.user = { osConfig, config, ... }: {
        imports = [
          ../../home/nixos.nix
          ../../home/base
          ../../home/tmpfs-as-home.nix
        ];

        tmpfs-as-home = {
          enable = osConfig.modules.tmpfs-as-root.enable;
          storage = osConfig.modules.tmpfs-as-root.storage + config.home.homeDirectory;
        };
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
      # modern unix commands
      fzf
      bat
      eza
      du-dust # modern du
      fd # find
      httpie # modern curl
      hyperfine # benchmarking tool
      ncdu # du
      sd #modern sed
      procs # modern ps
      ripgrep # modern grep
      choose # modern cut
      delta # diff

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

      iotop
      btop
      s-tui
      stress

      jq
      git
      inetutils
      inotify-tools
      netcat-openbsd
      p7zip
      pigz
      (python3.withPackages config.modules.base.pythonPackages)
      wget
      monolith # Save complete web pages as a single HTML file
      file
      python3Packages.yq
      openssl
      unixtools.xxd
      nix-index
      socat
      bc
      dig
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
    };

    # mDNS
    services.avahi = {
      enable = true;
      nssmdns = true; # *.local resolution
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
