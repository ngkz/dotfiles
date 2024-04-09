{ fetchzip, ngkz, lib, ... }:
ngkz.buildChromiumExtension rec {
  pname = "ublock0";
  version = "1.57.2";
  src = fetchzip {
    url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
    sha256 = "15ix4qsw66fz0rmwf5slb99hl8gmkrr34n1wxkzpwqrzf4bbvzb5";
  };
}
