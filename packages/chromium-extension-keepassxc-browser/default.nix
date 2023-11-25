{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.8.10";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "0r1hb7b8d2nl85lwd37621pllmsjwhxx20gm02z2m41a1dd44hxx";
    stripRoot = false;
  };
}
