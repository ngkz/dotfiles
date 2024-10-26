{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.9.4";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "0zxfwdfn3dnax8w0rl7aqncfy17d22bg7rcm7pra7vzv9vd6aw4d";
    stripRoot = false;
  };
}
