{ stdenvNoCC, bash, coreutils, borgbackup, btrfs-progs, util-linux, cryptsetup, rsync, libsecret, gawk, gnused, findutils, nettools, udisks, gnugrep, bashInteractive, systemd, ... }:
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
    cryptsetup
    rsync
    libsecret
    gawk
    findutils
    gnused
    nettools
    udisks
    gnugrep
    util-linux
    systemd
  ];

  installPhase = ''
    mkdir -p $out/bin
    substituteAll ${./backup} $out/bin/backup
    chmod a+x $out/bin/*
  '';
}
