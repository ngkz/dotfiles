{ fcitx5-mozc, fetchurl, ... }:
let
  utdicver = "20220525";
  mozcdic-ut = fetchurl {
    url = "https://osdn.net/users/utuhiro/pf/utuhiro/dl/mozcdic-ut-${utdicver}.tar.bz2";
    sha256 = "0prlgkn1v31y6n159qx6684plflb5371hz3p0c1i2xyz1m1bfrx8";
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
