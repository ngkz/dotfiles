{ pkgs, ... }: {
  home.packages = with pkgs; [
    wineWowPackages.waylandFull # XXX current winewayland.drv does not support text-input protocol :(
    winetricks
  ];

  home.tmpfs-as-home.persistentDirs = [
    ".wine"
  ];
}
