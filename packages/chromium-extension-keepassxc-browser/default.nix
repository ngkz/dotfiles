{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.8.8";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "0irxld7n0k53z9vv7b9igva2rcjwsf1j7y9bwqa0wxgl9yw11f7k";
    stripRoot = false;
  };
}
