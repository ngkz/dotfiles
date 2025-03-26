{ lib
, stdenvNoCC
, fetchFromGitHub
, gtk3
, adwaita-icon-theme
, adwaita-icon-theme-legacy
, hicolor-icon-theme
}:

stdenvNoCC.mkDerivation rec {
  pname = "adwaita-colors-icon-theme";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "dpejoh";
    repo = "Adwaita-colors";
    rev = "v${version}";
    hash = "sha256-M5dFb759sXfpD9/gQVF3sngyW4WdSgy4usInds9VIWk=";
  };

  nativeBuildInputs = [
    gtk3
  ];

  propagatedBuildInputs = [
    adwaita-icon-theme
    adwaita-icon-theme-legacy
    hicolor-icon-theme
  ];

  dontDropIconThemeCache = true;
  dontPatchELF = true;
  dontRewriteSymlinks = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons
    cp -a Adwaita-* $out/share/icons/

    for theme in $out/share/icons/*; do
      gtk-update-icon-cache "$theme"
    done

    runHook postInstall
  '';
}
