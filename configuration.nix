# configuration applied to all hosts

{ config, pkgs, ... }:

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
    secrets.grub-password-hash.file = ./secrets/grub-password-hash.age;
    sshKeyPaths = [ "/nix/persist/secrets/age.key" ];
  };

  users = {
    mutableUsers = false;

    users = {
      # disable root login
      root.hashedPassword = "*";

      # define a primary user account
      user = {
        isNormalUser = true;
        uid = 1000;
        group = "user";
        extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
        shell = pkgs.zsh;
        passwordFile = config.age.secrets.user-password-hash.path;
      };
    };

    groups = {
      user.gid = 1000;
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

  systemd.tmpfiles.rules = [
    "L /boot - - - - /nix/persist/boot"
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
  home-manager.useGlobalPkgs = true;
  #home-manager.users.user = { pkgs, ... }: {
  #  aj
  #};

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  #environment.systemPackages = with pkgs; [
  #];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

