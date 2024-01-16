{ config, ... }: {
  imports = [
    ./tmpfs-as-home.nix
  ];

  tmpfs-as-home.persistentDirs = [
    ".cache/nix-index"
  ];

  home.packages = with pkgs; [
    nix-index
  ];
}
