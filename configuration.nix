# configuration applied to all hosts

{ config, lib, pkgs, ... }:

{
  # Enable experimental flakes feature
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "ja_JP.UTF-8";
  console = {
    font = "Lat2-VGA8";
    keyMap = "jp106";
  };


  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # tmpfs /tmp
  boot.tmpOnTmpfs = true;

  # agenix
  age = {
    secrets.user-password-hash.file = ./secrets/user-password-hash.age;
    sshKeyPaths = [ "/nix/persist/secrets/age.key" ];
  };

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
        passwordFile = config.age.secrets.user-password-hash.path;
      };
    };
  };

  # "tmpfs as root" setup
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["size=2G" "mode=755" "noexec" "nodev" "nosuid"];
    };

    "/nix" = {
      label = "nix";
      fsType = "xfs";
    };

    "/nix/persist/boot/efi" = {
      label = "ESP";
      fsType = "vfat";
    };

    "/var/log" = {
      device = "/nix/persist/var/log";
      fsType = "none";
      options = [ "bind" ];
    };
  };

  swapDevices = [
    {
      label = "swap";
      # TODO stable nixos doesn't support this yet
      #discardPolicy = "once";
    }
  ];

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/nix/persist/boot/efi"; # ESP mount point
    };

    grub = {
      enable = true;
      efiSupport = true;

      # install-grub.pl goes bananas if /boot or /nix are bind-mount or symlink
      # Relocate /boot to /nix/persist/boot
      mirroredBoots = [{
        path = "/nix/persist/boot";
        devices = [ "nodev" ];
        efiSysMountPoint = config.boot.loader.efi.efiSysMountPoint;
      }];
    };
  };

  environment.etc = {
    #nixos.source = "/nix/persist/etc/nixos";
    adjtime.source = "/nix/persist/etc/adjtime";
    machine-id.source = "/nix/persist/etc/machine-id";
  };

  systemd.tmpfiles.rules = lib.mkBefore [
    "L /boot - - - - /nix/persist/boot"

    "d /nix/persist/home/user 700 user users -"

    # xdg cache home
    "d /nix/persist/home/user/.cache - user users -"
    "d /home/user/.cache - user users -"

    # xdg data home
    "d /nix/persist/home/user/.local - user users -"
    "d /nix/persist/home/user/.local/share - user users -"
    "d /home/user/.local - user users -"
    "d /home/user/.local/share - user users -"

    # Nix
    "d /nix/persist/home/user/.cache/nix - user users -"
    "L /home/user/.cache/nix - - - - /nix/persist/home/user/.cache/nix"
    "d /nix/persist/home/user/.local/share/nix - user users -"
    "L /home/user/.local/share/nix - - - - /nix/persist/home/user/.local/share/nix"
  ];

  # sudo
  security.sudo = {
    execWheelOnly = true;
    extraConfig = ''
      # rollback results in sudo lectures after each reboot
      Defaults lecture = never
    '';
  };

  # Z Shell
  programs.zsh.enable = true;

  # neovim
  programs.neovim.enable = true;
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # home-manager
  home-manager.useGlobalPkgs = true; # use global nixpkgs
  # install per-user packages to /etc/profiles to make nixos-rebuild build-vm work
  home-manager.useUserPackages = true;
  home-manager.users.user = { pkgs, ... }: {
    home.stateVersion = config.system.stateVersion;

    # enable ~/.config, ~/.cache and ~/.local/share management
    xdg.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search nixpkgs wget
  environment.systemPackages = with pkgs; [
    bat
    borgbackup
    bpytop
    exa
    fd
    fzf
    git
    hddtemp
    inetutils
    iotop
    lm_sensors
    ncdu
    netcat-openbsd
    parted
    python3
    ripgrep
    s-tui
    smartmontools #smartctl
    termshark
    tldr
    usbutils #lsusb
    wget
  ];

  services.udev.extraRules = ''
    # set scheduler for NVMe SSD
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
    # set scheduler for SATA SSD and eMMC
    ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    # set scheduler for rotating disks
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';

  # Remap Caps Lock
  # Control when held down, Escape when tapped
  services.interception-tools = {
    enable = true;
    # Stable caps2esc doesn't support '-m' option.
    # TODO remove below line after 21.09 upgrade
    plugins = [ pkgs.unstable.interception-tools-plugins.caps2esc ];
    # Simple mode (No Esc to Caps)
    udevmonConfig = ''
      - JOB: "intercept -g $DEVNODE | caps2esc -m 1 | uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK]
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

