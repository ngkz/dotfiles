{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.8.2.1";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "0smfvi3pyg87i81ghjnjfawx2gjjwnlba76fg45gwa8v3hzr4c8b";
    stripRoot = false;
  };
}
