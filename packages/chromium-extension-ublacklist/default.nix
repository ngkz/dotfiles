{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublacklist";
  version = "7.8.5";
  src = fetchzip {
    url = "https://github.com/iorate/ublacklist/releases/download/v${version}/ublacklist-v${version}-chrome.zip";
    sha256 = "1f8can5k1d1q7h02hnn2sqcbz170p9m39nairll7gkasqp15wsfh";
    stripRoot = false;
  };
}
