{ lib, stdenvNoCC, fetchgit, ... }:
stdenvNoCC.mkDerivation rec {
  pname = "blobmoji-fontconfig";
  version = "1.0.0-2";

  src = fetchgit {
    url = "https://aur.archlinux.org/blobmoji-fontconfig.git";
    rev = "5fe763d82394c4a31b88f8fad0a62d170cb18c71";
    sha256 = "02dsyc1y5d8g1hgk92qhzv5hrra0hhlmh0vid7sa58c0kqrj22rg";
  };

  phases = "installPhase";

  installPhase = ''
    install -Dm644 $src/75-blobmoji.conf $out/etc/fonts/conf.d/75-blobmoji.conf
  '';

  meta = with lib; {
    description = "Fontconfig to enable Blobmoji fonts where emojis can be displayed";
    homepage = "https://aur.archlinux.org/packages/blobmoji-fontconfig";
    license = licenses.gpl2;
    platforms = platforms.all;
  };
}
