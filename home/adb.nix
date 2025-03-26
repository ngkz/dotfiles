{ pkgs, ... }: {
  imports = [
    ./tmpfs-as-home.nix
  ];

  tmpfs-as-home.persistentDirs = [
    ".android"
  ];

  home.packages = [
    pkgs.android-tools
  ];
}

