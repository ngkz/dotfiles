{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.48.8";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "18w73wdkzlhrc6zjj63hlry17q67ib2qvyg77wpmgpj1hl3xvd55";
  };
}
