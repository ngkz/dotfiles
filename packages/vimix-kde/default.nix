{ lib, bash, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "vimix-kde";
  version = "${builtins.substring 0 6 src.rev}";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "vimix-kde";
    rev = "29c43163eb099e4046f4bf32da984c2dda6e4c5c";
    sha256 = "DLwZ6vfmZmSP3pv1hKbEX4KKg/iue+i2snfQpK60MKo=";
  };

  phases = "unpackPhase patchPhase installPhase";

  patchPhase = ''
    sed -iE -e "s@\$HOME/.local/share@$out/share@" -e "s@\$HOME/.config/Kvantum@$out/share/Kvantum@" -e 's@/bin/bash@${bash}&@' install.sh
  '';

  installPhase = ''
    ./install.sh
  '';
}
