{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublacklist";
  version = "7.8.0";
  src = fetchzip {
    url = "https://github.com/iorate/ublacklist/releases/download/v${version}/ublacklist-v${version}-chrome.zip";
    sha256 = "0lh6f0db1pjsdgwrgapk8jp4043bvnfv9cy0v5aylqqcanjsb1d6";
    stripRoot = false;
  };
}
