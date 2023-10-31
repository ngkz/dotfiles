{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.53.0";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "12aa6q0rrzb2g97s94rkx6m8sx9hzvxlb1zvm1g10w5nsrx0y8ka";
  };
}
