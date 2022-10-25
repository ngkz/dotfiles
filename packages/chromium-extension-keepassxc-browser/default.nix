{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.8.3";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "0m8l3v5jrm8xmy116ljxa1ji9ll5whbavpmah66iklc3gf3fpbz9";
    stripRoot = false;
  };
}
