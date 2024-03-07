{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.9.0.1";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "1s6y137frahpdhl1nzfd31cgjrwmlyyprahg7r7h93jz2kc1p3cb";
    stripRoot = false;
  };
}
