{ pkgs, ... }: {
  modules.tmpfs-as-root.persistentDirs = [
    "/root/.cache/borg"
    "/root/.config/borg"
  ];

  environment.systemPackages = with pkgs; [
    ngkz.backup
    borgbackup
  ];

  boot.initrd.kernelModules = [
    "dm-snapshot"
  ];
}
