{ inputs, config, pkgs, ... }:

{
  networking.hostName = "mauritius";

  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    ../../modules/agenix.nix
    ../../modules/base.nix
    ../../modules/desktop-essential.nix
    ../../modules/fonts.nix
    ../../modules/nix-maintenance
    ../../modules/ssh.nix
  ];

  wsl = {
    enable = true;
    defaultUser = "user";
    # useWindowsDriver = true;
    startMenuLaunchers = true;
  };

  # https://stackoverflow.com/questions/63960859/how-can-i-raise-the-limit-for-open-files-in-ubuntu-20-04-on-wsl2
  systemd.user.extraConfig = ''
    DefaultLimitNOFILE=65535
  '';

  age.identityPaths = [ "/etc/age.key" ];

  # user
  age.secrets.user-password-hash-mauritius.file = ../../secrets/user-password-hash-mauritius.age;
  users.users.user.hashedPasswordFile = config.age.secrets.user-password-hash-mauritius.path;
  security.sudo.wheelNeedsPassword = true;

  home-manager.users.user.imports = [
    ../../home/hacking
    ../../home/dev-docs.nix
    ../../home/git.nix
    ../../home/doom-emacs
    ../../home/direnv.nix
    ../../home/user-dirs.nix
    ../../home/cli-extended.nix
    ../../home/desktop-essential.nix
    ../../home/ssh.nix
    ../../home/im
  ];

  environment.systemPackages = with pkgs; [
    wsl-open
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
