# Syncthing
{ config, osConfig, pkgs, ... }:
let
  syncthingCfgDir = "${config.xdg.configHome}/syncthing";
  syncthingCfg = "${syncthingCfgDir}/config.xml";
in
{
  imports = [
    ./tmpfs-as-home.nix
  ];

  services.syncthing = {
    enable = true;
  };

  programs.gnome-shell.extensions = with pkgs.gnomeExtensions; [
    { package = syncthing-indicator; }
  ];

  systemd.user.services.syncthing = {
    Unit.X-Restart-Triggers = [
      "${config.systemd.user.services.syncthing.Service.ExecStartPre}"
    ];
    Service.ExecStartPre = pkgs.writeShellScript "syncthing-config.sh"
      (pkgs.ngkz.generateSyncthingConfigUpdateScript {
        configDir = syncthingCfgDir;
        storage = config.home.homeDirectory;
        secrets = osConfig.age.secrets.syncthing.path;
        hostname = config.systemName;
      });
  };

  tmpfs-as-home.persistentDirs = [
    ".config/syncthing"
    ".local/share/syncthing"
  ];
}
