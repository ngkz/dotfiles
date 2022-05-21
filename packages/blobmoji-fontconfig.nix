{ lib, stdenv, fetchurl, ... }:

let
  rev = "5fe763d82394c4a31b88f8fad0a62d170cb18c71";
in
stdenv.mkDerivation rec {
  pname = "blobmoji-fontconfig";
  version = "1.0.0-2";

  src = fetchurl {
    name = "75-blobmoji.conf";
    url = "https://aur.archlinux.org/cgit/aur.git/plain/75-blobmoji.conf?h=${pname}&id=${rev}";
    sha256 = "sha256-Rii/yZYIj+GsSLipwrNgjmsOeQ/bPKHamiS3wdwynSY=";
  };

  phases = "installPhase";

  installPhase = ''
    install -Dm644 $src $out/etc/fonts/conf.d/75-blobmoji.conf
  '';

  meta = with lib; {
    description = "Fontconfig to enable Blobmoji fonts where emojis can be displayed";
    homepage = "https://aur.archlinux.org/packages/blobmoji-fontconfig";
    license = licenses.gpl2;
    platforms = platforms.all;
  };
}
