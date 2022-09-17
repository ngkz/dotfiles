{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.8.2.2";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "0gallk44lqilz4jm0mdsqxvd9pqspjdli3mjd6bgrqrgijcv2m08";
    stripRoot = false;
  };
}
