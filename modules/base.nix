# configuration applied to all hosts

{ config, lib, pkgs, inputs, ... }:
let
  inherit (lib) mapAttrs filterAttrs attrValues mkIf;
  inherit (inputs) self agenix home-manager;
in
{
  imports = [
    agenix.nixosModules.age
    home-manager.nixosModule
    self.nixosModules.tmpfs-as-root
  ];

  nixpkgs = import ../nixpkgs.nix { inherit inputs; };

  # Enable experimental flakes feature
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes ca-references

      # Keep build-time dependencies when GC
      keep-outputs = true
      keep-derivations = true
    '';

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

  swapDevices = [
    {
      label = "swap";
      # TODO stable nixos doesn't support this yet
      #discardPolicy = "once";
    }
  ];

  # sudo
  security.sudo = {
    execWheelOnly = true;
    extraConfig = ''
      # rollback results in sudo lectures after each reboot
      Defaults lecture = never
    '';
  };

  # home-manager
  home-manager.useGlobalPkgs = true; # use global nixpkgs
  # install per-user packages to /etc/profiles to make nixos-rebuild build-vm work
  home-manager.useUserPackages = true;
  home-manager.users.user = self.homeManagerModules.base;

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

