{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.9.0.3";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "1ibadw2wq2ha7fjcihv20fs8a733cg9ijvvdkrglx6g1kbhhi8z0";
    stripRoot = false;
  };
}
