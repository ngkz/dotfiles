{ lib, bash, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "vimix-kde";
  version = "${builtins.substring 0 6 src.rev}";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "vimix-kde";
    rev = "cf5b8f6136cff0b679b31006bae6fea182c23fe2";
    hash = "sha256-uj4ItnRuAo5vz+tcY++EOiKuO7QfIfouL3dUdulQAbM=";
  };

  phases = "unpackPhase patchPhase installPhase";

  patchPhase = ''
    sed -iE -e "s@\$HOME/.local/share@$out/share@" -e "s@\$HOME/.config/Kvantum@$out/share/Kvantum@" -e 's@/bin/bash@${bash}&@' install.sh
  '';

  installPhase = ''
    ./install.sh
  '';
}
