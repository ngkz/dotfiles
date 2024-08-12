{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.9.2";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "1zfsxj3hy764g6cdr58gfdh5a9lgvbxls9sdfpdspsg26nprfp1f";
    stripRoot = false;
  };
}
