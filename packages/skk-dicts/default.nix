{ lib
, stdenv
, fetchFromGitHub
, gzip
, gawk
, gnutar
, gnused
, ruby
, skktools
}:

let
  dict_rev = "b7de5cd70aac106d9dd20898531357fbf4ca4707";
  dict_hash = "sha256-VJOr0zvmnicZ8SO2VJujhr5K2LGOPeJpWz83YIvwSg0=";
  tools_rev = "1e8c457c2796c2e3d84badcf41386506d5010a7e";
  tools_hash = "sha256-8sG6fMqoKjZ7c0S6O8Nf/GWv1y3TzZmE3FaJgp0YoRg=";
in
stdenv.mkDerivation {
  pname = "skk-dicts-unstable";
  version = "2023-12-26";

  srcs = [
    (fetchFromGitHub rec {
      owner = "skk-dev";
      repo = "dict";
      rev = dict_rev;
      hash = dict_hash;
      name = repo;
    })
    (fetchFromGitHub {
      owner = "skk-dev";
      repo = "skktools";
      rev = tools_rev;
      hash = tools_hash;
      name = "tools";
    })
  ];
  sourceRoot = "dict";

  nativeBuildInputs = [
    skktools
    gzip
    gawk
    gnutar
    gnused
    ruby
  ];

  strictDeps = true;

  preBuild = ''
    makeFlagsArray+=(RM="rm -f" all)
  '';

  installPhase = ''
    mkdir -p $out/share
    cp SKK-JISYO.* $out/share/

    # combine .L .edict and .assoc for convenience
    dst=$out/share/SKK-JISYO.combined
    skkdic-expr2 \
      $out/share/SKK-JISYO.L + \
      $out/share/SKK-JISYO.edict + \
      $out/share/SKK-JISYO.assoc >> $dst
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "A collection of standard SKK dictionaries";
    longDescription = ''
      This package provides a collection of standard kana-to-kanji
      dictionaries for the SKK Japanese input method.
    '';
    homepage = "https://github.com/skk-dev/dict";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ yuriaisaka ];
    platforms = platforms.all;
  };
}
