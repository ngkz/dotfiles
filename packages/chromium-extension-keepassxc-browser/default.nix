{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.8.5.1";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "0fs3f3bkhxs96jbi73816i5dm4mpfkhhi01jigq3hznkd47daync";
    stripRoot = false;
  };
}
