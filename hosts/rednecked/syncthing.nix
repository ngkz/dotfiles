{ config, pkgs, ... }:
let
  cfg = config.services.syncthing;
  storage = "/var/spinningrust/syncthing";
in
{
  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8384";
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22000 8384 ]; # tailscale only

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

  tmpfs-as-root.persistentDirs = [ cfg.dataDir ];

  systemd.tmpfiles.rules = [
    "d ${storage} 0700 syncthing syncthing -"
  ];

  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;
}

