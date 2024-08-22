# User accounts
{ pkgs, ... }:

{
  imports = [
    ./home-manager.nix
  ];

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

  home-manager.users.user = { osConfig, ... }: {
    imports = [
      ../home/nixos.nix
      ../home/base.nix
      ../home/cli-base.nix
    ];

    tmpfs-as-home.enable = osConfig.tmpfs-as-root.enable;
  };
}
