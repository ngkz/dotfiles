{ fcitx5-mozc, fetchurl, ... }:
let
  utdicver = "20220423";
  mozcdic-ut = fetchurl {
    url = "https://osdn.net/users/utuhiro/pf/utuhiro/dl/mozcdic-ut-${utdicver}.tar.bz2";
    sha256 = "1sa7ymz2hgk94cwx2kpfm9fwxqqa43irz89j7591r3jyhp8nrzj1";
  };
in
fcitx5-mozc.overrideAttrs (oldAttrs: {
  pname = "fcitx5-mozc-ut";
  version = "${oldAttrs.version}.${utdicver}";

  postUnpack = oldAttrs.postUnpack + ''
    tar -xf ${mozcdic-ut}
    cat mozcdic-ut-${utdicver}/mozcdic-ut-${utdicver}.txt >> $sourceRoot/src/data/dictionary_oss/dictionary00.txt
  '';
})
