{ clangStdenv, fcitx5-mozc, fetchzip, ... }:
let
  utdicver = "20230107";
in
(fcitx5-mozc.override {
  inherit clangStdenv; # make clangStdenv overridable
}).overrideAttrs (finalAttrs: previousAttrs: {
  pname = "fcitx5-mozc-ut";
  version = "${previousAttrs.version}.${utdicver}";

  postUnpack = previousAttrs.postUnpack + ''
    tar -xf ${./mozcdic-ut-20230107.tar.bz2}
    cat mozcdic-ut-${utdicver}/mozcdic-ut-${utdicver}.txt >> $sourceRoot/src/data/dictionary_oss/dictionary00.txt
  '';
})
