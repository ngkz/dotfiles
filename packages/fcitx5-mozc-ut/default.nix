{ clangStdenv, fcitx5-mozc, fetchzip, ... }:
let
  utdicver = "20221022";
  mozcdic-ut = fetchzip {
    url = "https://osdn.net/users/utuhiro/pf/utuhiro/dl/mozcdic-ut-${utdicver}.tar.bz2";
    sha256 = "1fcyrymcpgi38pfjvzg8pcvygvw0h66dbgzin68nxjwz1hizwpm0";
  };
in
(fcitx5-mozc.override {
  inherit clangStdenv; # make clangStdenv overridable
}).overrideAttrs (finalAttrs: previousAttrs: {
  pname = "fcitx5-mozc-ut";
  version = "${previousAttrs.version}.${utdicver}";

  postUnpack = previousAttrs.postUnpack + ''
    cat ${mozcdic-ut}/mozcdic-ut-${utdicver}.txt >> $sourceRoot/src/data/dictionary_oss/dictionary00.txt
  '';
})
