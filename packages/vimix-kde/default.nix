{ lib, bash, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "vimix-kde";
  version = "${builtins.substring 0 6 src.rev}";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "vimix-kde";
    rev = "42d434229587b3a57f8b1b11c352d8a33c5513ea";
    hash = "sha256-3trh8JHIv3p2L3xBitdofx8gWUXDxiTbILxlnBgE7TI=";
  };

  phases = "unpackPhase patchPhase installPhase";

  patchPhase = ''
    sed -iE -e "s@\$HOME/.local/share@$out/share@" -e "s@\$HOME/.config/Kvantum@$out/share/Kvantum@" -e 's@/bin/bash@${bash}&@' install.sh
  '';

  installPhase = ''
    ./install.sh
  '';
}
