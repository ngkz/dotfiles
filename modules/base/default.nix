# configuration applied to all hosts

{ config, lib, pkgs, inputs, ... }:
let
  inherit (lib) mapAttrs filterAttrs mapAttrsToList mkIf;
  inherit (inputs) self agenix home-manager;
in
{
  imports = [
    agenix.nixosModule
    home-manager.nixosModule
    self.nixosModules.tmpfs-as-root
    ./ccache.nix
  ];

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

  # build packages on the disk
  systemd.services.nix-daemon.environment.TMPDIR = "/nix/tmp";

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
  boot.tmpOnTmpfs = true;

  # agenix
  age = {
    secrets.user-password-hash.file = ../../secrets/user-password-hash.age;
    identityPaths = [ "${config.modules.tmpfs-as-root.storage}/secrets/age.key" ];
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
    users.user = self.homeManagerModules.base;
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
    ntfs3g
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

  # XXX Apply home.sessionPath when logined via ssh
  programs.zsh.enable = true;

  # XXX Apply home.sessionVariables. Workaround for home-manager #1011
  environment.extraInit = ''
    if [ -e "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
      . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
    fi
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
