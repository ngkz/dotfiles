{ lib
, stdenvNoCC
, bash
, coreutils
, git
, ...
}:
stdenvNoCC.mkDerivation rec {
  name = "scripts";

  preferLocalBuild = true;
  phases = "installPhase";
  inherit bash;

  installPhase = ''
    mkdir -p $out/bin
    substitute ${./git-change-time.sh} $out/bin/git-change-time \
               --subst-var bash \
               --subst-var-by path "${lib.makeBinPath [bash git coreutils]}"
    chmod a+x $out/bin/*
  '';
}
