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
  dict_rev = "1909dda026e6038975359a5eaeafcf50c9ce7fa3";
  dict_sha256 = "e7B1+ji/8ssM92RSTmlu8c7V5kbk93CxtUDzs26gE8s=";
  tools_rev = "3e130ed05493f6f2a534da34b09f8f97411ef4b4";
  tools_sha256 = "d6cYqVL+M/IJMvVNJp3pzB/GtpXh0zhu9pCynP6xxIc=";
in
stdenv.mkDerivation {
  pname = "skk-dicts-unstable";
  version = "2023-02-07";

  srcs = [
    (fetchFromGitHub rec {
      owner = "skk-dev";
      repo = "dict";
      rev = dict_rev;
      sha256 = dict_sha256;
      name = repo;
    })
    (fetchFromGitHub {
      owner = "skk-dev";
      repo = "skktools";
      rev = tools_rev;
      sha256 = tools_sha256;
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
