{ config, pkgs, lib, ... }: {
  tmpfs-as-root.persistentDirs = [
    "/root/.cache/borg"
    "/root/.config/borg"
  ];

  environment.systemPackages = with pkgs; [
    borgbackup
    (substituteAll {
      name = "backup";
      dir = "bin";
      src = ./backup.sh;
      isExecutable = true;
      inherit bash bashInteractive;
      path = lib.makeBinPath [
        bash
        coreutils
        borgbackup
        btrfs-progs
        rsync
        libsecret
        findutils
        gnused
        nettools
        gnugrep
        util-linux
        systemd
        config.services.openssh.package
      ];
    })
  ];
}
