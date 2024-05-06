{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.9.0.4";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "03y7ldljk3sdrxq3f5r33nx0d6dlcljmcchgvqqr0c3jrxwl0ajp";
    stripRoot = false;
  };
}
