{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.8.0";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "0pszzfwny4n7ckkc0cc05c5nk6akar38idvqnhq8kn3l1i6pyv27";
    stripRoot = false;
  };
}
