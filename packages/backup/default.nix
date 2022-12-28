{ stdenvNoCC, bash, coreutils, borgbackup, lvm2, util-linux, cryptsetup, rsync, libsecret, gawk, gnused, findutils, nettools, udisks, gnugrep, bashInteractive, ... }:
stdenvNoCC.mkDerivation rec {
  name = "backup";

  preferLocalBuild = true;
  phases = "installPhase";

  inherit bash coreutils borgbackup cryptsetup rsync libsecret gawk gnused findutils nettools udisks gnugrep bashInteractive;
  utilLinux = util-linux;
  lvm2Bin = lvm2.bin;

  installPhase = ''
    mkdir -p $out/bin
    substituteAll ${./backup} $out/bin/backup
    chmod a+x $out/bin/*
  '';
}
