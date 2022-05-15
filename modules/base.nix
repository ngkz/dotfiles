# configuration applied to all hosts

{ config, lib, pkgs, inputs, ... }:
let
  inherit (lib) mapAttrs filterAttrs attrValues mkIf;
  inherit (inputs) self agenix home-manager;
in
{
  imports = [
    agenix.nixosModule
    home-manager.nixosModule
    self.nixosModules.tmpfs-as-root
  ];

  nixpkgs = import ../nixpkgs.nix { inherit inputs; };

  # Enable experimental flakes feature
  nix = {
    # Enable flake
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes

      # Keep build-time dependencies when GC
      keep-outputs = true
      keep-derivations = true
    '';

    # Only allow administrative users to connect the nix daemon
    allowedUsers = [ "root" "@wheel" ];

    trustedUsers = [ "root" ];

    # Automatic nix store deduplication
    autoOptimiseStore = true;

    # Periodically remove old generations
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # It’s often convenient to pin the nixpkgs flake to the exact version
    # of nixpkgs used to build the system. This ensures that commands
    # like nix shell nixpkgs#<package> work more efficiently since
    # many or all of the dependencies of <package> will already be
    # present.
    registry = mapAttrs (_: value: { flake = value; }) (
      filterAttrs (name: _: name != "self") inputs);
  };

  # Let 'nixos-version --json' know the Git revision of this flake.
  system.configurationRevision = mkIf (self ? rev) self.rev;

  # Select internationalisation properties.
  i18n.defaultLocale = "ja_JP.UTF-8";
  console = {
    font = "lat2-12";
    keyMap = "jp106";
  };

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # tmpfs /tmp
  boot.tmpOnTmpfs = true;

  # agenix
  age = {
    secrets.user-password-hash.file = ../secrets/user-password-hash.age;
    identityPaths = [ "/nix/persist/secrets/age.key" ];
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
    sharedModules = [
      # Workaround for https://github.com/nix-community/home-manager/issues/1262 TODO
      { manual.manpages.enable = false; }
    ];
  };

  environment.pathsToLink = [ "/share/zsh" ]; #zsh

  # List packages installed in system profile. To search, run:
  # $ nix search nixpkgs wget
  #environment.systemPackages = with pkgs; [
  #];

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

  # Remap Caps Lock
  # Control when held down, Escape when tapped
  services.interception-tools = {
    enable = true;
    # Simple mode (No Esc to Caps)
    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc -m 1 | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK]
    '';
  };

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
  system.stateVersion = "21.05"; # Did you read the comment?

}

