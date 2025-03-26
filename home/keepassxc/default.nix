# KeePassXC
{ pkgs, ... }:

{
  # TODO switch to xdg.autostart after 25.05 upgrade
  xdg.configFile."autostart/org.keepassxc.KeePassXC.desktop".source = "${pkgs.keepassxc}/share/applications/org.keepassxc.KeePassXC.desktop";

  xdg.configFile."keepassxc/keepassxc.ini".source = ./config.ini;
  # TODO switch to xdg.cacheFile after 25.05 upgrade
  home.file.".cache/keepassxc/keepassxc.ini".source = ./cache.ini;

  home.packages = with pkgs; [
    keepassxc
  ];
}
