{ pkgs, ... }: {
  home.packages = with pkgs; [
    wineWowPackages.waylandFull
    winetricks
  ];

  home.tmpfs-as-home.persistentDirs = [
    ".wine"
  ];
}
