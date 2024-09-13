{ stdenvNoCC, bash, coreutils, borgbackup, btrfs-progs, util-linux, rsync, libsecret, gnused, findutils, nettools, gnugrep, bashInteractive, systemd, openssh, ... }:
stdenvNoCC.mkDerivation rec {
  name = "backup";

  preferLocalBuild = true;
  phases = "installPhase";

  inherit bash bashInteractive;
  path = [
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
    openssh
  ];

  installPhase = ''
    mkdir -p $out/bin
    substituteAll ${./backup} $out/bin/backup
    chmod a+x $out/bin/*
  '';
}
