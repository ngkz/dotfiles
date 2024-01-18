{ config, osConfig, pkgs, lib, ... }:
let
  xq = "${pkgs.python3Packages.yq}/bin/xq";
  sed = "${pkgs.gnused}/bin/sed";

  syncthingCfgDir = "${config.xdg.configHome}/syncthing";
  syncthingCfg = "${syncthingCfgDir}/config.xml";
  syncthingTrayCfg = "${config.xdg.configHome}/syncthingtray.ini";
in
{
  # Syncthing
  services.syncthing = {
    enable = true;
    tray.enable = true;
  };

  systemd.user.services.syncthingtray = {
    Unit.X-Restart-Triggers = [
      "${config.systemd.user.services.syncthingtray.Service.ExecStartPre}"
    ];
    Service = {
      Restart = "on-failure";
      Environment = [
        "PATH=/etc/profiles/per-user/%u/bin" # XXX Qt find plugins from PATH
      ];
      ExecStartPre = pkgs.writeShellScript "syncthingtray-config.sh" ''
        set -euo pipefail
        newConfig=$(${sed} "s/@apiKey@/$(${xq} -r ".configuration.gui.apikey" ${syncthingCfg})/g" ${./syncthingtray.ini})
        if [ ! -e ${syncthingTrayCfg} ] || [ "$(<${syncthingTrayCfg})" != "$newConfig" ]; then
          echo "config changed, updating"
          echo "$newConfig" >${syncthingTrayCfg}
        fi
      '';
    };
  };

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
