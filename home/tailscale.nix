{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [ trayscale ];

  systemd.user.services.trayscale = {
    Unit = {
      Description = "Tailscale GUI";
      Requires = [ "tray.target" ];
      After = [ "graphical-session-pre.target" "tray.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };

    Service = {
      ExecStart = "${lib.getExe pkgs.trayscale} --hide-window";
      Restart = "on-failure";
    };
  };
}
