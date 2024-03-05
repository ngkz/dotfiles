{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.9.0";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "1hnl2chg06ihn1syw67n7kyszrg4dgp7cx5pfikc9zbzicyraqfs";
    stripRoot = false;
  };
}
