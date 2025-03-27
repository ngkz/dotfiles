{ pkgs, ... }:

{
  imports = [
    ../tmpfs-as-home.nix
  ];


  home.packages = with pkgs; [
    signal-desktop
  ];

  tmpfs-as-home.persistentFiles = [
    ".config/Signal/config.json"
  ];

  tmpfs-as-home.persistentDirs = [
    ".config/Signal/Local Storage"
    ".config/Signal/IndexedDB"
    ".config/Signal/logs"
    ".config/Signal/sql"
    ".config/Signal/attachments.noindex"
    ".config/Signal/avatars.noindex"
    ".config/Signal/badges.noindex"
    ".config/Signal/stickers.noindex"
    ".config/Signal/update-cache"
    ".config/Signal/drafts.noindex"
    ".config/Signal/downloads.noindex"
  ];

  xdg.configFile."Signal/ephemeral.json".source = ./ephemeral.json;

  # TODO switch to xdg.autostart after 25.05 upgrade
  xdg.configFile."autostart/signal-desktop.desktop".source = "${pkgs.signal-desktop}/share/applications/signal-desktop.desktop";
}
