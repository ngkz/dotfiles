{ fetchFromGitHub, stdenvNoCC, gawk }:

stdenvNoCC.mkDerivation {
  pname = "ical2org";
  version = "unstable-2024-01-09";
  src = fetchFromGitHub {
    owner = "msherry";
    repo = "ical2org";
    rev = "7e50d4ca8da8f830418a4aff70faa76571c44f2e";
    hash = "sha256-BEdvaRWG+aax+qT9CtQyjnOOaKPbFRCx5ZDoxRMr5vw=";
  };

  installPhase = ''
    install -Dm755 ical2org.awk $out/bin/ical2org
    sed -i "1 s|#!/usr/bin/env -S gawk|#!${gawk}/bin/gawk|" $out/bin/ical2org
  '';
}
