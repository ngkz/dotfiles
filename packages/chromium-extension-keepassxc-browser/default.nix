{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.8.4";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "1hq08v9grfxpwv9yz3rcvxw5a6qinblh1a8a3l8mfxid2rb79fm4";
    stripRoot = false;
  };
}
