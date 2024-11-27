{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "keepassxc-browser";
  version = "1.9.5";
  src = fetchzip {
    url = "https://github.com/keepassxreboot/keepassxc-browser/releases/download/${version}/keepassxc-browser_${version}_chromium.zip";
    sha256 = "0lianjxfyxachqwccxld2vkhxzlsw7hk2zkgvpfrhqjbn6hc7j68";
    stripRoot = false;
  };
}
