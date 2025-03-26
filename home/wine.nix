{ pkgs, ... }: {
  home.packages = with pkgs; [
    wineWow64Packages.waylandFull # XXX current winewayland.drv does not support text-input protocol :(
    winetricks
  ];

  tmpfs-as-home.persistentDirs = [
    ".wine"
  ];
}
