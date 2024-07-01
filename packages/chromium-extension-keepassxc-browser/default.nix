{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.9.1";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "1y2max5wj49dhv8738zhr1i39m4gbx7vqb6nzp3vwmb1zz7m6cxl";
    stripRoot = false;
  };
}
