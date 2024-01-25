{ pkgs, ... }:

{
  imports = [
    ./tmpfs-as-home.nix
  ];

  home.packages = with pkgs; [ gtkcord4 ];
  tmpfs-as-home.persistentDirs = [
    ".cache/gtkcord4"
    ".config/gtkcord4"
  ];
  xdg.enable = true;
  xdg.desktopEntries."so.libdb.gtkcord4" = {
    name = "gtkcord4";
    genericName = "Discord Chat";
    comment = "A Discord client in Go and GTK4";
    exec = "gtkcord4";
    icon = "gtkcord4";
    terminal = false;
    type = "Application";
    categories = [ "GNOME" "GTK" "Network" "Chat" ];
    startupNotify = true;
    settings = {
      DBusActivatable = "false";
      X-GNOME-UsesNotification = "true";
      X-Purism-FormFactor = "Workstation;Mobile;";
    };
  };
}
