{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublacklist";
  version = "7.8.4";
  src = fetchzip {
    url = "https://github.com/iorate/ublacklist/releases/download/v${version}/ublacklist-v${version}-chrome.zip";
    sha256 = "0xs6v1cz4ypnf27sbc1cs4gpjid5zqi6i3q2jsmh08gsrblmln87";
    stripRoot = false;
  };
}
