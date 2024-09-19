{ pkgs, ... }:
{
  imports = [
    ./tmpfs-as-home.nix
  ];

  home.packages = with pkgs; [
    telegram-desktop
  ];

  tmpfs-as-home.persistentDirs = [
    ".local/share/TelegramDesktop"
  ];

  systemd.user.services.telegram-desktop = {
    Unit = {
      Description = "Telegram client";
      Requires = [ "tray.target" ];
      After = [ "graphical-session-pre.target" "tray.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };

    Service = {
      ExecStart = "${pkgs.telegram-desktop}/bin/telegram-desktop -autostart";
    };
  };
}
