{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.9.0.5";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "1s07555phv4xfn9rbic99kzqys6nprpwci9fyqd6y7z8pcdrkaqw";
    stripRoot = false;
  };
}
