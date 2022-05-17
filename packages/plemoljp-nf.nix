{ lib, fetchzip }:

let
  version = "1.2.4";
in fetchzip {
  name = "plemoljp-nf-${version}";

  url = "https://github.com/yuru7/PlemolJP/releases/download/v${version}/PlemolJP_NF_v${version}.zip";
  sha256 = "sha256-nDnHOybBpou8LaUIAd5mbxJtC3kwpMnfRpIUNKPSpSY=";

  postFetch = ''
    unzip $downloadedFile
    install -m444 -Dt $out/share/fonts/truetype PlemolJP_NF_v${version}/*/*.ttf
  '';

  meta = with lib; {
    description = "A japanese programming font based on IBM Plex Mono and IBM Plex Sans JP (with Nerd Font griffs)";
    homepage = "https://github.com/yuru7/PlemolJP";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
