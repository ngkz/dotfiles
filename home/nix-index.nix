{ config, pkgs, ... }: {
  imports = [
    ./tmpfs-as-home.nix
  ];

  tmpfs-as-home.persistentDirs = [
    ".cache/nix-index"
  ];

  programs.nix-index.enable = true;
}
