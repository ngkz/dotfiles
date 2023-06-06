{ stdenvNoCC }:

stdenvNoCC.mkDerivation rec {
  pname = "vcr-eas-font";
  version = "3.0";

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    install -m444 -Dt $out/share/fonts/truetype ${./VCREAS_3.0.ttf}
  '';
}
