{ lib, bash, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "vimix-kde";
  version = "${builtins.substring 0 6 src.rev}";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "vimix-kde";
    rev = "e03243ef4f6a6b7a57331823ae5dbe4df30c8567";
    hash = "sha256-uvJL7BfRXcgNj/5lR6jJNJTzW7myy5aINCmsl5y6/fA=";
  };

  phases = "unpackPhase patchPhase installPhase";

  patchPhase = ''
    sed -iE -e "s@\$HOME/.local/share@$out/share@" -e "s@\$HOME/.config/Kvantum@$out/share/Kvantum@" -e 's@/bin/bash@${bash}&@' install.sh
  '';

  installPhase = ''
    ./install.sh
  '';
}
