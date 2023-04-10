{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.8.6.1";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "159dbpjmgk3p00l3yqra7n9rrvb7qrfjyx5ck9hkmdi91q25qd4j";
    stripRoot = false;
  };
}
