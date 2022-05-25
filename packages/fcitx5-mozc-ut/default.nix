{ fcitx5-mozc, ... }:
let
  utdicver = "20220525";
  mozcdic-ut = builtins.fetchTarball {
    url = "https://osdn.net/users/utuhiro/pf/utuhiro/dl/mozcdic-ut-${utdicver}.tar.bz2";
    sha256 = "1951wwyq5gcfdnfx1k8qdvydh8xv0nhn00jhkn5jxpkk4ng1bskh";
  };
in
fcitx5-mozc.overrideAttrs (oldAttrs: {
  pname = "fcitx5-mozc-ut";
  version = "${oldAttrs.version}.${utdicver}";

  postUnpack = oldAttrs.postUnpack + ''
    cat ${mozcdic-ut}/mozcdic-ut-${utdicver}.txt >> $sourceRoot/src/data/dictionary_oss/dictionary00.txt
  '';
})
