{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.8.2";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "180ajfg66bicvll0dfzl1lf3l9qs9sqh00yjdgrsdnj67gnnhxrh";
    stripRoot = false;
  };
}
