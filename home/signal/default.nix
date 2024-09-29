{ pkgs, ... }:

{
  imports = [
    ../tmpfs-as-home.nix
  ];

  xdg.enable = true;

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

  systemd.user.services.signal-desktop = {
    Unit = {
      Description = "Signal desktop client";
      Requires = [ "tray.target" ];
      After = [ "graphical-session-pre.target" "tray.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };

    Service = {
      ExecStart = "${pkgs.signal-desktop}/bin/signal-desktop --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform-hint=auto";
    };
  };
}
