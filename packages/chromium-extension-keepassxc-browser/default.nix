{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.9.1.1";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "18va53cwdxajjg09v06i4azggg8d0qvp03jykf839qfhzmvwl9qw";
    stripRoot = false;
  };
}
