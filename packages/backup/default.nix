{ stdenvNoCC, bash, coreutils, borgbackup, lvm2, util-linux, cryptsetup, rsync, libsecret, gawk, gnused, findutils, nettools, udisks, gnugrep, bashInteractive, ... }:
stdenvNoCC.mkDerivation rec {
  name = "backup";

  preferLocalBuild = true;
  phases = "installPhase";

  inherit bash bashInteractive;
  path = [ bash coreutils borgbackup lvm2.bin cryptsetup rsync libsecret gawk findutils gnused nettools udisks gnugrep util-linux ];

  installPhase = ''
    mkdir -p $out/bin
    substituteAll ${./backup} $out/bin/backup
    chmod a+x $out/bin/*
  '';
}
