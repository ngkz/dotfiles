{ pkgs, ... }: {
  home.packages = with pkgs; [
    zim
  ];

  home.tmpfs-as-home.persistentDirs = [
    ".config/zim"
  ];
}
