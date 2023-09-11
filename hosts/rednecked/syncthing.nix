{ lib, config, pkgs, ... }:
let
  cfg = config.services.syncthing;
  storage = "/var/spinningrust/syncthing";
in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
  };

  age.secrets.syncthing = {
    file = ../../secrets/syncthing.json.age;
    owner = cfg.user;
    group = cfg.group;
    mode = "0400";
  };

  systemd.services.syncthing.preStart = pkgs.ngkz.generateSyncthingConfigUpdateScript {
    configDir = cfg.configDir;
    inherit storage;
    secrets = config.age.secrets.syncthing.path;
    hostname = config.system.name;
  };

  modules.tmpfs-as-root.persistentDirs = [ cfg.dataDir ];

  hosts.rednecked.network.internalInterfaces.allowedTCPPorts = [ 8384 ];

  systemd.tmpfiles.rules = [
    "d ${storage} 0700 syncthing syncthing -"
  ];
}

